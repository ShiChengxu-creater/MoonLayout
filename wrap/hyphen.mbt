///|
/// Wrap using discretionary word-internal hyphens. Providers receive UAX #29
/// word segments; offsets must be interior UTF-8 bytes on grapheme boundaries.
/// Invalid/duplicate offsets are ignored. A visible ASCII hyphen is inserted
/// only at a selected break and never changes source or start/end offsets.
pub fn[H : @hyphen.Hyphenator] wrap_hyphenated(
  s : String,
  max_width : Int,
  hyphenator : H,
  algorithm? : WrapAlgorithm = Greedy,
  opts? : WrapOptions = WrapOptions::new(),
  optimal? : OptimalOptions = OptimalOptions::new(),
) -> Array[Line] {
  let points : Map[Int, Bool] = Map([])
  let mut offset = 0
  for word in @segment.words(s) {
    let size = @text.byte_length(word)
    for point in hyphenator.positions(word) {
      if point > 0 && point < size {
        points.set(offset + point, true)
      }
    }
    offset += size
  }
  match algorithm {
    Greedy => greedy_points(s, max_width, opts, points)
    Optimal => optimal_points(s, max_width, opts, optimal, points)
  }
}
