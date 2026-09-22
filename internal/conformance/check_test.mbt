///|
test "valid/fixture checker counts every code point and UTF-8 boundary" {
  let (count, failures) = @conformance.check("× 0061 ÷ 4E00 ÷", fn(_) {
    [1, 4]
  })
  assert_eq(count, 1)
  assert_eq(failures, [])
}

///|
test "invalid/negative control detects a wrong boundary implementation" {
  let (count, failures) = @conformance.check("× 0061 ÷", fn(_) { [] })
  assert_eq(count, 1)
  assert_eq(failures.length(), 2)
  assert_true(failures[1].contains("1 / 1 cases failed"))
}
