///|
test "valid/greedy words and source reconstruction" {
  let lines = @wrap.wrap("hello world", 5)
  assert_eq(lines.map(fn(l) { l.text }), ["hello", "world"])
  assert_eq(lines.map(fn(l) { l.source }).join(""), "hello world")
  assert_eq(lines[0].start, 0)
  assert_eq(lines[0].end, 6)
  assert_eq(lines[0].width, 5)
  assert_eq(lines[0].break_kind, @wrap.Soft)
  assert_eq(lines[1].break_kind, @wrap.End)
}

///|
test "valid/CJK emoji and forced long tokens" {
  assert_eq(@wrap.wrap("你好世界", 4).map(fn(l) { l.text }), [
    "你好", "世界",
  ])
  assert_eq(@wrap.wrap("abcdef", 2).map(fn(l) { l.text }), ["ab", "cd", "ef"])
  assert_eq(@wrap.wrap("abcdef", 2)[0].break_kind, @wrap.Forced)
  assert_eq(@wrap.wrap("a\u{301}b", 1).map(fn(l) { l.text }), ["a\u{301}", "b"])
  assert_eq(@wrap.wrap("👩‍🔬🇨🇳x", 2).map(fn(l) { l.text }), [
    "👩‍🔬", "🇨🇳", "x",
  ])
  assert_eq(@wrap.wrap("你", 1)[0].width, 2)
}

///|
test "edge/empty zero negative width and hard blank lines" {
  assert_eq(@wrap.wrap("", 5).length(), 0)
  assert_eq(@wrap.wrap("ab", 0).map(fn(l) { l.text }), ["a", "b"])
  assert_eq(@wrap.wrap("ab", -2).map(fn(l) { l.text }), ["a", "b"])
  let lines = @wrap.wrap("a\r\n\n", 20)
  assert_eq(lines.map(fn(l) { l.text }), ["a", "", ""])
  assert_eq(lines.map(fn(l) { l.source }).join(""), "a\r\n\n")
  assert_eq(lines[0].break_kind, @wrap.Hard)
  assert_eq(lines[1].break_kind, @wrap.Hard)
  assert_eq(lines[2].break_kind, @wrap.End)
  assert_eq(@wrap.wrap("  ", 0)[0].text, "")
}

///|
test "valid/tabs ambiguity and boundary policies" {
  assert_eq(@wrap.wrap("a\tb", 10)[0].text, "a   b")
  assert_eq(@wrap.display_width("a\tb"), 5)
  let opts = @wrap.WrapOptions::new(ambiguous_wide=true)
  assert_eq(@wrap.wrap("··", 2, opts~).map(fn(l) { l.text }), ["·", "·"])
  let word = @wrap.WrapOptions::new(break_policy=@wrap.Word)
  assert_eq(@wrap.wrap("hello world", 7, opts=word).map(fn(l) { l.text }), [
    "hello", "world",
  ])
  let sentence = @wrap.WrapOptions::new(break_policy=@wrap.Sentence)
  assert_eq(@wrap.wrap("Hi! Bye!", 5, opts=sentence).map(fn(l) { l.text }), [
    "Hi!", "Bye!",
  ])
}

///|
test "property/source spans are contiguous and grapheme-safe" {
  for
    input in [
      "hello  world", "你好吗？abc", "👩‍🔬🇨🇳e\u{301}", "\r\nA\n",
      "a\tb", "\u{200B}abc", "  a  ",
    ] {
    for width in [0, 1, 2, 4, 9] {
      let lines = @wrap.wrap(input, width)
      let boundaries = [0]
      for g in @grapheme.grapheme_iter(input) {
        boundaries.push(
          boundaries[boundaries.length() - 1] + @text.byte_length(g.to_owned()),
        )
      }
      assert_eq(lines.map(fn(l) { l.source }).join(""), input)
      let mut offset = 0
      for line in lines {
        assert_eq(line.start, offset)
        assert_true(line.end >= line.start)
        assert_true(boundaries.contains(line.start))
        assert_true(boundaries.contains(line.end))
        assert_eq(line.end - line.start, @text.byte_length(line.source))
        assert_eq(line.width, @wrap.display_width(line.text))
        offset = line.end
      }
    }
  }
}
