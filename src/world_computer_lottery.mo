import Array          "mo:base/Array";
import Blob           "mo:base/Blob";
import Debug          "mo:base/Debug";
import Error          "mo:base/Error";
import Float          "mo:base/Float";
import Int            "mo:base/Int";
import Int64          "mo:base/Int64";
import Iter           "mo:base/Iter";
import Nat            "mo:base/Nat";
import Nat64          "mo:base/Nat64";
import Option         "mo:base/Option";
import Principal      "mo:base/Principal";
import Text           "mo:base/Text";
import Time           "mo:base/Time";
import { setTimer } = "mo:base/Timer";

import Index "canister:icp_index_canister";
import Ledger "canister:icp_ledger_canister";

import Lib "./lib";
import Hex "./hex";

actor WorldComputerLottery {

  let PRICE : Nat64 = 1_000_000;// 0.01 ICP (e8s)
  let TRANSFER_FEE : Nat64 = 10_000;// 0.0001 ICP
  let E8S_PER_ICP : Nat64 = 100_000_000;
  let JACKPOT_ACCOUNT : {owner : Principal; subaccount : ?[Nat8]} = { owner = Principal.fromActor(WorldComputerLottery); subaccount = null };
  let JACKPOT_ACCOUNT_TEXT : Text = Hex.encode(Principal.toLedgerAccount(JACKPOT_ACCOUNT.owner, Option.map<[Nat8], Blob>(JACKPOT_ACCOUNT.subaccount, Blob.fromArray)));

  type Ticket = { account : Blob; chosen_numbers : [Nat] };
  stable var lastSeenId : Nat64 = 0;
  stable var drawNo     : Nat = 0;

  // TODO stream instead of buffer (to avoid blowing memory limit when the world starts playing)
  private func fetchTickets() : async [Ticket] {
    
    let page_size : Nat = 2;
    
    var start         : ?Nat     = null;// for paging (start with most recent)
    var keepPaging    : Bool     = true;
    var reachedOldTx  : Bool     = false;
    var newestIdSeen  : ?Nat64   = null;
    var tickets       : [Ticket] = [];

    label pageLoop while (keepPaging and not reachedOldTx) {
      
      switch (await Index.get_account_transactions({ account = JACKPOT_ACCOUNT; max_results = page_size; start = start })) {
        case (#Ok ok) {
          if (ok.transactions.size() == 0) break pageLoop;
		  
          if (start == null) {
            newestIdSeen := ?ok.transactions[0].id;
          };

          label txLoop for (t in ok.transactions.vals()) {
            if (t.id <= lastSeenId) { reachedOldTx := true; break txLoop };

            switch (t.transaction.operation) {
              case (#Transfer tr) {
                if (tr.amount.e8s >= PRICE and Text.toLowercase(tr.to) == JACKPOT_ACCOUNT_TEXT) {// ignore underpaid and payout transactions
				  tickets := Array.append(
				    tickets,
				    [{ account = Hex.decode(tr.from); chosen_numbers = Lib.decode(t.transaction.memo) }]// TODO, handle failure to decode memo
				  );
                };
              };
              case _ {};// ignore Mint / Burn / Approve
            };
          };

          if (reachedOldTx or ok.transactions.size() < page_size) {
            keepPaging := false;
          };

          start := ?Nat64.toNat(ok.transactions[ok.transactions.size() - 1].id);
        };

        case (#Err e) {
			throw Error.reject(e.message)
        };
      };
    };

    switch (newestIdSeen) { case (?id) { lastSeenId := id }; case null {} };

    tickets
  };

  // example -> tierLabel(3) = "          🎯🎯🎯"
  private func tierLabel(k : Nat) : Text {// TODO, turn this into a simple lookup table (simpler to read)
    let darts : Nat = if (k > 8) 8 else k;
    let blanks : Nat = 8 - darts;
    var t = "";
    var i : Nat = 0;
    while (i < blanks)    { t #= "  "; i += 1 };
    while (i < 8)         { t #= "🎯"; i += 1 };
    t
  };

  private func executeDraw() : async () {
    
    drawNo += 1;
    Debug.print("---------- WORLD COMPUTER LOTTERY, Draw No." # Nat.toText(drawNo) # " (demo) ----------");

    let pot : Nat64 = (await Ledger.account_balance({ account = Principal.toLedgerAccount(JACKPOT_ACCOUNT.owner, Option.map<[Nat8], Blob>(JACKPOT_ACCOUNT.subaccount, Blob.fromArray)) })).e8s;
    let winning = await Lib.draw();

    Debug.print("NUMBERS, " # debug_show(winning));

    // TODO consider pontential for memory exhaustion (too many tickets). We should process a stream rather than a buffer.
    let tickets =
      try {
        await fetchTickets()
      } catch e {
        Debug.print("ERR: " # Error.message(e));
        Debug.print("ROLLING OVER DUE TO FAILURE - all tickets will be included in next week's draw.");
        return;// bail out
      };
    Debug.print("TICKETS COLLECTED, " # Nat.toText(tickets.size()) # " (up to transaction " # Nat64.toText(lastSeenId) # ")");
    
    var buckets : [var [Blob]] = Array.init<[Blob]>(9, []);// 0..8
    
    for (t in tickets.vals()) {
      let k = Lib.matches(t.chosen_numbers, winning);
      if (k > 0) {
        buckets[k] := Array.append<Blob>(buckets[k], [t.account]);
      }
    };

    var histogram : Text = "WINNERS";
    for (k in Iter.range(1, 8)) {
      let n = buckets[k].size();
      if (n > 0) {
        histogram #= ", " # Text.trimStart(tierLabel(k), #char ' ') # ": " # Nat.toText(n);
      }
    };
    if (histogram == "WINNERS") {
      Debug.print(histogram # ", none");
      Debug.print("JACKPOT ROLLOVER, " # Float.toText(Float.fromInt64(Int64.fromNat64(pot)) / Float.fromInt64(Int64.fromNat64(E8S_PER_ICP))) # " ICP");
      return;// nothing to do
    };
    Debug.print(histogram);  
    Debug.print("JACKPOT, " # Float.toText(Float.fromInt64(Int64.fromNat64(pot)) / Float.fromInt64(Int64.fromNat64(E8S_PER_ICP))) # " ICP");

    // fixed weights for different tiers of winners
    let weight : [Nat64] = [0, 1, 2, 3, 4, 5, 6, 7, 70];
    
    // count transfer failures. TODO retry and subtract outstanding retries from available pot in case of persistent failures
    var failed : Nat = 0;

	// pay out to winners
    label tiers for (k in Iter.range(1, 8)) {
      let winners = buckets[k];
      if (winners.size() == 0) { continue tiers };// nobody won this tier
    
      let tierPot : Nat64 = pot * weight[k] / 100;
      let payout  : Nat64 = tierPot / Nat64.fromNat(winners.size());// equal split between winners for this tier

      Debug.print("Tier " # Nat.toText(k) # " " # tierLabel(k) # ": " # Nat64.toText(weight[k]) # "% of "
                  # Float.toText(Float.fromInt64(Int64.fromNat64(pot)) / Float.fromInt64(Int64.fromNat64(E8S_PER_ICP))) 
                  # " ICP Jackpot between " # Nat.toText(winners.size()) # " winner(s), minus "
                  # Float.toText(Float.fromInt64(Int64.fromNat64(TRANSFER_FEE)) / Float.fromInt64(Int64.fromNat64(E8S_PER_ICP))) # " transfer fee = " 
                  # Float.toText(Float.fromInt64(Int64.fromNat64(payout) - Int64.fromNat64(TRANSFER_FEE)) / Float.fromInt64(Int64.fromNat64(E8S_PER_ICP)))
                  # " ICP payout each");
      
      // This is impossible unless the transfer fee changes (given that every ticket is more than enough to cover it's own payout transfer fee)
      // TODO Check what gaurantees there are. If we're going to blackhole this we should load the transfer_fee dynamically
      if (payout <= TRANSFER_FEE) {
        continue tiers 
      }; 
    
      for (account in winners.vals()) {
        try {
          ignore await Ledger.transfer({
            to              = account;
            fee             = { e8s = TRANSFER_FEE };
            memo            = 0 : Nat64;
            from_subaccount = null;
            created_at_time = null;
            amount          = { e8s = payout - TRANSFER_FEE }
          });
        } catch e { 
          Debug.print(Error.message(e));
          failed += 1 
        }
      };
    };

    Debug.print("Canister ledger account " # JACKPOT_ACCOUNT_TEXT # " proves payouts and ticket purchases");

    // TODO, print current cycles balance

    // TODO, retries with exponential backoff
    if (failed > 0) {
      Debug.print("ERR transfers failed: " # Nat.toText(failed));
    };
  };

  private func weeklyDraw() : async () {
    try {
      // Schedule next week's draw immediately
      // TODO, consider if there's a need to catch and retry failures to reschedule
      ignore setTimer<system>(
        #nanoseconds (Lib.inOneMinute() - Int.abs(Time.now())),
        func () : async () { await weeklyDraw(); }
      );
      await executeDraw();
    } catch e {
      Debug.print("ERR executeDraw: " # Error.message(e));
    }
  };

  let wait : Nat = Lib.inOneMinute() - Int.abs(Time.now());
  Debug.print("Scheduling method = inOneMinute");
  ignore setTimer<system>(
    #nanoseconds wait,
    func () : async () { await weeklyDraw(); }
  );
}

