///|
test "valid/UTF-8 breaks and mandatory CRLF" {
  assert_eq(@linebreak.line_break_opportunities("abc def"), [4, 7])
  assert_eq(@linebreak.line_break_opportunities("你好"), [3, 6])
  assert_eq(@linebreak.line_break_opportunities("a\r\nb"), [3, 4])
  assert_eq(@linebreak.line_break_opportunities("a\u{0301}b"), [4])
}

///|
test "edge/empty and invalid boundary indices" {
  assert_eq(@linebreak.line_break_opportunities(""), [0])
  assert_false(@linebreak.is_breakable_at("你好", 1))
  assert_false(@linebreak.is_breakable_at("你好", -1))
  assert_false(@linebreak.is_breakable_at("你好", 7))
  assert_false(@linebreak.is_breakable_at("abc", 0))
  assert_true(@linebreak.is_breakable_at("你好", 3))
}
