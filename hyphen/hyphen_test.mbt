///|
test "valid/Liang overlay even suppression and margins" {
  let h = @hyphen.Liang::new(["a1b", "ab2c", "b3c"], left_min=1, right_min=1)
  assert_eq(h.positions("abcd"), [1, 2])
  let suppress = @hyphen.Liang::new(["a1b", "a2b"], left_min=1, right_min=1)
  assert_eq(suppress.positions("abc"), [])
  assert_eq(h.positions("ABCD"), [1, 2])
  assert_eq(h.positions("éabcd"), [])
  assert_eq(h.positions("a-b"), [])
  assert_eq(@hyphen.Liang::new(["a1b"]).positions("ab"), [])
}

///|
test "valid/English patterns and exceptions" {
  let h = @hyphen.Liang::english()
  assert_eq(h.positions("hyphenation"), [2, 6])
  assert_eq(h.positions("representation"), [3, 5, 8, 10])
  assert_eq(h.positions("project"), [])
  assert_eq(h.positions(""), [])
  let custom = @hyphen.Liang::new(
    [],
    exceptions=["ab-cd-ef"],
    left_min=1,
    right_min=1,
  )
  assert_eq(custom.positions("abcdef"), [2, 4])
}
