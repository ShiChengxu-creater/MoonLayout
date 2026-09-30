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

///|
test "regr/optimal oversized grapheme retains following hard break" {
  let lines = @wrap.optimal_wrap("你\r\n", 1)
  assert_eq(lines.map(fn(l) { l.text }), ["你", ""])
  assert_eq(lines[0].break_kind, @wrap.Hard)
  assert_eq(lines[0].source, "你\r\n")
  assert_eq(@wrap.optimal_wrap("你  \n", 1)[0].source, "你  \n")
}

///|
fn exhaustive_cost(words : Array[Int], start : Int, width : Int) -> Int {
  if start == words.length() {
    return 0
  }
  let mut best = 1000000
  let mut used = 0
  for end = start; end < words.length(); end = end + 1 {
    used += words[end] + (if end > start { 1 } else { 0 })
    if used > width {
      break
    }
    let slack = width - used
    let own = if end + 1 == words.length() { 1 } else { 1 + slack * slack }
    let total = own + exhaustive_cost(words, end + 1, width)
    if total < best {
      best = total
    }
  }
  best
}

///|
test "property/optimal matches exhaustive small paragraph oracle" {
  for a in [1, 2, 3] {
    for b in [1, 2, 3] {
      for c in [1, 2, 3] {
        for d in [1, 2, 3] {
          let sizes = [a, b, c, d]
          let s = sizes.map(fn(n) { "x".repeat(n) }).join(" ")
          for width in [3, 4, 5, 6, 7, 8] {
            let lines = @wrap.optimal_wrap(s, width)
            let mut cost = 0
            for i, line in lines {
              assert_true(line.break_kind != @wrap.Forced)
              let slack = width - line.width
              cost += 1 +
                (if i + 1 == lines.length() { 0 } else { slack * slack })
            }
            assert_eq(cost, exhaustive_cost(sizes, 0, width))
          }
        }
      }
    }
  }
}
