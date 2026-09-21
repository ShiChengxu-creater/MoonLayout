///|
fn main {
  for
    line in @ml.layout(
      "MoonLayout: 你好，MoonBit！",
      @ml.LayoutStyle::new(16),
    ) {
    println(line.aligned_text)
  }
}
