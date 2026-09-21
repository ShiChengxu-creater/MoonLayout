///|
test "valid/left right center and overflow" {
  let lines = @wrap.wrap("abc", 10)
  assert_eq(@align.align_lines(lines, 6, @align.Left), ["abc   "])
  assert_eq(@align.align_lines(lines, 6, @align.Right), ["   abc"])
  assert_eq(@align.align_lines(lines, 6, @align.Center), [" abc  "])
  assert_eq(@align.align_lines(lines, 2, @align.Right), ["abc"])
  assert_eq(@align.align_lines(lines, -1, @align.Center), ["abc"])
}

///|
test "valid/justify words CJK and final line" {
  let words = @wrap.wrap("a b c d e", 5)
  assert_eq(@align.align_lines(words, 7, @align.Justify), ["a  b  c", "d e    "])
  let cjk = @wrap.wrap("你好世界", 4)
  assert_eq(@align.align_lines(cjk, 6, @align.Justify), ["你  好", "世界  "])
  let hard = @wrap.wrap("a b\nc d", 8)
  assert_eq(@align.align_lines(hard, 5, @align.Justify), ["a b  ", "c d  "])
}

///|
test "edge/empty no gaps and grapheme safety" {
  assert_eq(@align.align_lines([], 10, @align.Left), [])
  let lines = @wrap.wrap("👩‍🔬🇨🇳abc", 4)
  let output = @align.align_lines(lines, 7, @align.Justify)
  assert_true(output[0].contains("👩‍🔬"))
  assert_true(output[0].contains("🇨🇳"))
  assert_eq(@wrap.display_width(output[0]), 7)
  for alignment in [@align.Left, @align.Right, @align.Center, @align.Justify] {
    for text in @align.align_lines(@wrap.wrap("你好 a b c", 6), 8, alignment) {
      assert_eq(@wrap.display_width(text), 8)
    }
  }
}

///|
test "valid/ambiguous width is carried by each line" {
  let lines = @wrap.wrap(
    "·",
    2,
    opts=@wrap.WrapOptions::new(ambiguous_wide=true),
  )
  let output = @align.align_lines(lines, 4, @align.Center)
  assert_eq(output, [" · "])
  assert_eq(@wrap.display_width(output[0], ambiguous_wide=true), 4)
}
