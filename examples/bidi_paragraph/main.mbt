///|
fn main {
  let style = @ml.LayoutStyle::new(18, alignment=Right)
  let result = @integration.layout(
    "שלום עולם 123 — e\u{301} ABC\nمرحبا 456",
    style,
    normalization=NFC,
    bidi=true,
  )
  for line in result.lines {
    println("|\{line.aligned_text}| logical=\{line.source}")
  }
}
