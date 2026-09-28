///|
test "valid/optimal balances nonfinal lines" {
  let s = "aaa bb bb ccccc"
  let lines = @wrap.optimal_wrap(s, 6)
  assert_eq(lines.map(fn(l) { l.text }), ["aaa", "bb bb", "ccccc"])
  assert_eq(lines.map(fn(l) { l.source }).join(""), s)
  assert_eq(@wrap.wrap(s, 6).map(fn(l) { l.text }), ["aaa bb", "bb", "ccccc"])
}

///|
test "edge/optimal preserves hard breaks and graphemes" {
  for s in ["", "a\r\n\n", "👩‍🔬e\u{301}你好", "abcdef", "a\tb", "  "] {
    for width in [0, 1, 3, 10] {
      let lines = @wrap.optimal_wrap(s, width)
      assert_eq(lines.map(fn(l) { l.source }).join(""), s)
      let mut offset = 0
      for line in lines {
        assert_eq(line.start, offset)
        assert_eq(line.end - line.start, @text.byte_length(line.source))
        assert_eq(line.width, @wrap.display_width(line.text))
        offset = line.end
      }
    }
  }
  assert_eq(@wrap.optimal_wrap("a\n", 5).map(fn(l) { l.break_kind }), [
    @wrap.Hard,
    @wrap.End,
  ])
}

///|
test "valid/optimal configurable glue" {
  let shrink = @wrap.OptimalOptions::new(shrink=1, line_penalty=1000)
  let lines = @wrap.optimal_wrap("aa  bb", 5, optimal=shrink)
  assert_eq(lines.map(fn(l) { l.text }), ["aa bb"])
  assert_eq(lines[0].source, "aa  bb")
  let stretch = @wrap.OptimalOptions::new(stretch=2, line_penalty=1000)
  assert_eq(
    @wrap.optimal_wrap("a b ccccc", 5, optimal=stretch)[0].text,
    "a   b",
  )
}
