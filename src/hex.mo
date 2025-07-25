import Array "mo:base/Array";
import Blob  "mo:base/Blob";
import Char  "mo:base/Char";
import Debug "mo:base/Debug";
import Iter  "mo:base/Iter";
import Nat8  "mo:base/Nat8";
import Text  "mo:base/Text";

// TODO add a test that generates 10,000 or so random Blobs, encodes them, then decodes them back to the same blob
module {
  private let hex  : [Char] = [ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' ];
  private func decodeChar(c : Char) : Nat8 {
    for (i in hex.keys()) {
      let h = hex[i];
      if (h == c or Char.toText(h) == Text.toLowercase(Char.toText(c))) {
          return Nat8.fromNat(i);
      }
    };
    Debug.trap("Invalid character '" # Char.toText(c) # "' does not represent a hex encoding");
  };

  public func decode(t : Text) : Blob {
    let t_ = if (t.size() % 2 == 0) { t } else { "0" # t };
    let cs = Iter.toArray(t_.chars());
    let ns = Array.init<Nat8>(t_.size() / 2, 0);
      for (i in Iter.range(0, ns.size() - 1)) {
      let j = i * 2;
      let x0 = decodeChar(cs[j]);
      let x1 = decodeChar(cs[j + 1]);
      ns[i] := x0 * 16 + x1
    };
    Blob.fromArray(Array.freeze(ns));
  };

  public func encode(b : Blob) : Text {
    Text.toLowercase(Text.translate(debug_show(b), func(c) {
      if (Char.isAlphabetic(c) or Char.isDigit(c)) Text.fromChar(c) else "" // strip out delimiters
    }));
  };
};
