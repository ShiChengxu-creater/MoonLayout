///|
fn main {
  let style = @ml.LayoutStyle::new(18, alignment=Justify)
  for
    line in @ml.layout(
      "Unicode layout brings readable text to your terminal. 中文两端对齐也可以保持完整的字素。",
      style,
    ) {
    println("|\{line.aligned_text}|")
  }
}
