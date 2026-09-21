///|
test "valid/layout facade composes wrapping and alignment" {
  let style = @layout.LayoutStyle::new(6, alignment=Center)
  let lines = @layout.layout("你好 abc", style)
  assert_eq(lines.map(fn(l) { l.aligned_text }), [" 你好 ", " abc  "])
  assert_eq(lines.map(fn(l) { l.source }).join(""), "你好 abc")
  assert_eq(lines.map(fn(l) { l.width }), [6, 6])
}

///|
test "edge/layout empty and oversized grapheme" {
  assert_eq(@layout.layout("", @layout.LayoutStyle::new(4)).length(), 0)
  let line = @layout.layout("👩‍🔬", @layout.LayoutStyle::new(1))[0]
  assert_eq(line.width, 2)
  assert_eq(line.source, "👩‍🔬")
}
