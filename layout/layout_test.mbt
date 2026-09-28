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

///|
test "valid/optimal layout facade" {
  let style = @layout.LayoutStyle::new(6, wrap_algorithm=Optimal)
  assert_eq(@layout.layout("aaa bb bb ccccc", style).map(fn(l) { l.text }), [
    "aaa", "bb bb", "ccccc",
  ])
}

///|
test "valid/hyphenated layout facade" {
  let style = @layout.LayoutStyle::new(7, wrap_algorithm=Optimal)
  let lines = @layout.layout_hyphenated(
    "hyphenation",
    style,
    @hyphen.Liang::english(),
  )
  assert_eq(lines.map(fn(l) { l.text }), ["hyphen-", "ation"])
  assert_eq(lines.map(fn(l) { l.source }).join(""), "hyphenation")
  assert_eq(lines[1].aligned_text, "ation  ")
}
