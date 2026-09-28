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
  let text = @text.scan(s)
  for span in @segment.segments(s, @segment.Word) {
    let (offset, end) = span
    let start_scalar = match text.bytes.binary_search(offset) {
      Ok(i) => i
      Err(_) => continue
    }
    let end_scalar = match text.bytes.binary_search(end) {
      Ok(i) => i
      Err(_) => continue
    }
    let word = s[text.units[start_scalar]:text.units[end_scalar]].to_owned()
    let size = end - offset
    for point in hyphenator.positions(word) {
      if point > 0 && point < size {
        points.set(offset + point, true)
      }
    }
  }
  match algorithm {
    Greedy => greedy_points(s, max_width, opts, points)
    Optimal => optimal_points(s, max_width, opts, optimal, points)
  }
}
