///|
// Application composition, deliberately not a Markdown parser.
fn main {
  println("|MoonLayout report|")
  let h = @ml.Liang::english()
  for
    paragraph in [
      "Unicode-aware terminal paragraphs.", "Representation and hyphenation can improve narrow columns.",
      "中文混排 supports emoji 👩‍🔬.",
    ] {
    let lines = @ml.layout_hyphenated(
      paragraph,
      @ml.LayoutStyle::new(28, wrap_algorithm=Optimal, alignment=Justify),
      h,
    )
    for i, line in lines {
      let prefix = if i == 0 { "- " } else { "  " }
      println("|\{prefix}\{line.aligned_text}|")
    }
  }
}
