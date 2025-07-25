import Lib   "../src/lib";
import Iter  "mo:base/Iter";
import Array "mo:base/Array";
import Nat   "mo:base/Nat";
import Debug "mo:base/Debug";

let N_DRAWS   : Nat = 10_000;
let EXPECTED  : Nat = N_DRAWS * 8 / 100;
let TOLERANCE : Nat = EXPECTED / 100;
let LOW       : Nat = EXPECTED - TOLERANCE;
let HIGH      : Nat = EXPECTED + TOLERANCE;

var counts : [var Nat] = Array.init<Nat>(100, 0);

for (_ in Iter.range(0, N_DRAWS - 1)) {
  let balls = await Lib.draw();
  for (b in balls.vals()) {
    counts[b] := counts[b] + 1;
  }
};

for (idx in counts.keys()) {
  let c = counts[idx];
  if (c <= LOW or c >= HIGH) {
    Debug.print(
      "Value " # Nat.toText(idx) # " appears " # Nat.toText(c) # " times. Result should tend to " # Nat.toText(EXPECTED) # "."
    );
    assert false;
  }
};
