import Array  "mo:base/Array";
import Blob   "mo:base/Blob";
import Int    "mo:base/Int";
import Nat64  "mo:base/Nat64";
import Nat8   "mo:base/Nat8";
import Nat    "mo:base/Nat";
import Random "mo:base/Random";
import Time   "mo:base/Time";

module {
  public let DRAW_SIZE : Nat = 8;

  public func nextFriday8pm() : Nat {
    let WEEK_NS         : Nat = 7 * 24 * 60 * 60 * 1_000_000_000; // one week
    let FRIDAY_8PM_UTC  : Nat = 5 * 24 * 60 * 60 * 1_000_000_000  // Fri 00:00
                                  + 20 * 60 * 60 * 1_000_000_000; // + 20 h
    let now : Nat = Int.abs(Time.now());
    let nextWeekStart : Nat = ((now / WEEK_NS) + 1) * WEEK_NS;
    nextWeekStart + FRIDAY_8PM_UTC
  };

  // A build-time replacement for nextFriday8pm, facilitating easy observation of behaviour locally over much shorter timeframes.
  // Replace calls to nextFriday8pm for inOneMinute using:
  //    sed -i.bak 's/nextFriday8pm/inOneMinute/g'  src/world_computer_lottery.mo
  // Revert to production implementation using:
  //    mv -f src/world_computer_lottery.mo.bak src/world_computer_lottery.mo
  public func inOneMinute() : Nat {
    let ONE_MIN_NS : Nat = 60 * 1_000_000_000;
    Int.abs(Time.now()) + ONE_MIN_NS
  };

  // decodes a memo into an array of chosen draw numbers. TODO consider underflows and overflows
  public func decode(m : Nat64) : [Nat] {
    var v = m;
    var out : [Nat] = [];
    var i : Nat = 0;
    while (i < DRAW_SIZE) {
      out := Array.append(out, [Nat64.toNat(v % 100)]);
      v  := v / 100;
      i += 1;
    };
    out
  };

  public func matches(picks : [Nat], win : [Nat]) : Nat {
    var k : Nat = 0;
    for (p in picks.vals()) if (Array.indexOf<Nat>(p, win, Nat.equal) != null) k += 1;
    k
  };
  
  // TODO consider explicitly using time as a seed + jackpot balance (given that the draw runs on a schedule)
  public func draw() : async [Nat] {
    var rng = Random.Finite(await Random.blob());
    var balls : [Nat] = [];
    while (balls.size() < 8) {
      switch (rng.byte()) {
        case null {
          // Generator exhausted, so reseed and continue
          rng := Random.Finite(await Random.blob());
        };
        case (?b) {
          let n : Nat = Nat8.toNat(b) % 100;
          if (Array.indexOf<Nat>(n, balls, Nat.equal) == null) {
            balls := Array.append(balls, [n]);
          };
        };
      };
    };
    balls
  }
}
