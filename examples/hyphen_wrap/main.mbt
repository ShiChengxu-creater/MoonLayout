///|
fn main {
  let h = @ml.Liang::english()
  let style = @ml.LayoutStyle::new(9, wrap_algorithm=Optimal)
  for
    line in @ml.layout_hyphenated(
      "Hyphenation improves representation of narrow paragraphs.", style, h,
    ) {
    println("|\{line.aligned_text}| bytes=\{line.start}..\{line.end}")
  }
}
