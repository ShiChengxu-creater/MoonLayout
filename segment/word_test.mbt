///|
test "valid/word boundaries contractions and UTF-8" {
  assert_eq(@segment.word_boundaries("can't"), [0, 5])
  assert_eq(@segment.word_boundaries("你好"), [0, 3, 6])
  assert_eq(@segment.words("Hi, 你好 3.14!"), ["Hi", "你", "好", "3.14"])
}

///|
test "edge/word empty and ignored marks" {
  assert_eq(@segment.word_boundaries(""), [0])
  assert_eq(@segment.words("  !"), [])
  assert_eq(@segment.word_boundaries("a\u{301}b"), [0, 4])
  assert_eq(@segment.word_boundaries("\r\n"), [0, 2])
}
