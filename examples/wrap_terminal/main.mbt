///|
fn main {
  let input = "MoonLayout wraps terminal text without splitting 👩‍🔬 or e\u{301}."
  for line in @ml.wrap(input, 24) {
    println(
      "|\{line.text}| bytes=\{line.start}..\{line.end} width=\{line.width}",
    )
  }
}
