///|
test "valid/root consumer API" {
  let lines = @moonlayout.layout(
    "Hello 世界",
    @moonlayout.LayoutStyle::new(8),
  )
  assert_eq(lines.map(fn(l) { l.text }), ["Hello 世", "界"])
  assert_eq(@moonlayout.words("Hello 世界"), ["Hello", "世", "界"])
  assert_eq(@moonlayout.line_break_opportunities("你好"), [3, 6])
}
