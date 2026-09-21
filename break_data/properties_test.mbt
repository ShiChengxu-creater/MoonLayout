///|
test "valid/property range endpoints" {
  assert_eq(@break_data.line_break(0x41), @break_data.AL)
  assert_eq(@break_data.line_break(0x4E00), @break_data.ID)
  assert_eq(@break_data.line_break(0x1F1E6), @break_data.RI)
  assert_eq(@break_data.line_break(0x1F1FF), @break_data.RI)
  assert_eq(@break_data.word_break(0x41), @break_data.ALetter)
  assert_eq(@break_data.sentence_break(0x2E), @break_data.ATerm)
  assert_eq(
    @break_data.emoji_property(0x1F600),
    @break_data.Extended_Pictographic,
  )
  assert_eq(@break_data.general_category(0x301), @break_data.Mn)
  assert_eq(@break_data.east_asian_width(0x4E00), @break_data.W)
}

///|
test "edge/invalid and default properties" {
  for cp in [-1, 0x110000] {
    assert_eq(@break_data.line_break(cp), @break_data.XX)
    assert_eq(@break_data.word_break(cp), @break_data.Other)
    assert_eq(@break_data.sentence_break(cp), @break_data.Other)
    assert_eq(@break_data.general_category(cp), @break_data.Cn)
    assert_eq(@break_data.east_asian_width(cp), @break_data.N)
  }
}
