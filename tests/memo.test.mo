import Lib   "../src/lib";
import Nat64 "mo:base/Nat64";

// test memo decode
let memo : Nat64 = 706_050_403_020_100;
assert(Lib.decode(memo) == [0, 1, 2, 3, 4, 5, 6, 7]);
