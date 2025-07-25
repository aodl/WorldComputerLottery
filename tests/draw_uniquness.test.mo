import Lib   "../src/lib";
import Iter "mo:base/Iter";

// test draw uniqueness (1000 samples)
for (_ in Iter.range(0, 999)) {
  let balls = await Lib.draw();
  assert (balls.size() == Lib.DRAW_SIZE);
  for (i in balls.keys()) {
    for (j in balls.keys()) {
      if (i != j) assert (balls[i] != balls[j]);
    }
  }
}
