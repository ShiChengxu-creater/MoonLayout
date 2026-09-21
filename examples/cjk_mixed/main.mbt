///|
fn main {
  let style = @ml.LayoutStyle::new(16, alignment=Center)
  for
    line in @ml.layout(
      "你好，MoonBit！Unicode 排版支持中文、English 和 emoji 👩‍🔬。",
      style,
    ) {
    println("|\{line.aligned_text}|")
  }
}
