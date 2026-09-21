///|
test "valid/parse and compress unsorted adjacent ranges" {
  let rows = parse_ucd("0043 ; AL # C\n0041..0042 ; AL\n0044 ; NU\n")
  assert_eq(rows.length(), 2)
  assert_eq(rows[0].lo, 0x41)
  assert_eq(rows[0].hi, 0x43)
  assert_eq(rows[0].property, "AL")
}

///|
test "edge/comments and inclusive endpoints" {
  assert_eq(parse_ucd("# @missing: 0000..10FFFF; XX\n").length(), 0)
  let rows = parse_ucd("0000 ; XX\n10FFFF ; AL")
  assert_eq(rows[1].hi, 0x10FFFF)
}

///|
test "invalid/reject reversed overlapping and malformed ranges" {
  for
    input in [
      "0042..0041 ; AL", "110000 ; AL", "XYZ ; AL", "0041", "0041 ;", "0041..0042 ; AL\n0042 ; NU",
    ] {
    let rejected = try {
      ignore(parse_ucd(input))
      false
    } catch {
      _ => true
    }
    assert_true(rejected)
  }
}
