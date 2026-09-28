///|
test "valid/hyphenated greedy and optimal preserve source" {
  let h = @hyphen.Liang::english()
  for algorithm in [@wrap.Greedy, @wrap.Optimal] {
    let lines = @wrap.wrap_hyphenated("hyphenation", 7, h, algorithm~)
    assert_eq(lines.map(fn(l) { l.text }), ["hyphen-", "ation"])
    assert_eq(lines.map(fn(l) { l.source }).join(""), "hyphenation")
    assert_eq(lines[0].break_kind, @wrap.Hyphenated)
    assert_eq(lines[0].end, 6)
  }
  assert_eq(@wrap.wrap_hyphenated("hyphenation", 20, h)[0].text, "hyphenation")
}

///|
struct UnsafeProvider {}

///|
impl @hyphen.Hyphenator for UnsafeProvider with fn positions(_, _) {
  [100, 1, -1, 2, 2, 0]
}

///|
test "edge/provider points filtered to interior grapheme bytes" {
  for algorithm in [@wrap.Greedy, @wrap.Optimal] {
    let lines = @wrap.wrap_hyphenated(
      "éa\u{301}bc",
      3,
      UnsafeProvider::{ },
      algorithm~,
    )
    assert_eq(lines.map(fn(l) { l.source }).join(""), "éa\u{301}bc")
    for line in lines {
      assert_true(line.width <= 3)
    }
    assert_eq(
      @wrap.wrap_hyphenated("a\r\n", 3, UnsafeProvider::{ }, algorithm~).map(fn(
        l,
      ) {
        l.text
      }),
      ["a", ""],
    )
  }
}
