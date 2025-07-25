import Lib   "../src/lib";
  
let picks = [ 3, 14, 15, 92, 77, 51, 65,  9];
let win   = [92, 65, 35, 89, 79, 32, 38, 46];
assert (Lib.matches(picks, win) == 2);

