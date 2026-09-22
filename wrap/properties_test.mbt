///|
test "property/deterministic multilingual reconstruction and widths" {
  let alphabet = [
    "a", "b", " ", "\t", "你", "。", "👩‍🔬", "🇨🇳", "e\u{301}", "\u{200B}",
    "\n", "\r\n", "א", "·",
  ]
  for seed = 0; seed < 24; seed = seed + 1 {
    let input = StringBuilder()
    for i = 0; i < 18; i = i + 1 {
      input.write_string(
        alphabet[(seed * 7 + i * i + 3 * i) % alphabet.length()],
      )
    }
    let input = input.to_string()
    for width = 1; width <= 10; width = width + 1 {
      let lines = @wrap.wrap(input, width)
      assert_eq(lines.map(fn(line) { line.source }).join(""), input)
      let mut position = 0
      for line in lines {
        assert_eq(line.start, position)
        assert_eq(line.end - line.start, @text.byte_length(line.source))
        assert_eq(line.width, @wrap.display_width(line.aligned_text))
        if line.width > width {
          assert_eq(@grapheme.graphemes(line.text).length(), 1)
        }
        position = line.end
      }
      assert_eq(position, @text.byte_length(input))
    }
  }
}
