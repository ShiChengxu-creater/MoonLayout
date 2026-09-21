///|
/// Compare every official test boundary, reporting at most 12 counterexamples.
pub fn check(
  fixture : String,
  boundaries : (String) -> Array[Int],
) -> (Int, Array[String]) raise {
  let failures : Array[String] = []
  let mut count = 0
  let mut failed = 0
  for row in fixture.split("\n") {
    if row.trim().is_empty() {
      continue
    }
    count += 1
    let builder = StringBuilder()
    let expected : Array[Int] = []
    let mut offset = 0
    for part in row.split(" ") {
      if part == "÷" {
        expected.push(offset)
      } else if part != "×" && !part.is_empty() {
        let cp = @string.parse_int(part, base=16)
        builder.write_char(cp.unsafe_to_char())
        offset += if cp < 0x80 {
          1
        } else if cp < 0x800 {
          2
        } else if cp < 0x10000 {
          3
        } else {
          4
        }
      }
    }
    let actual = boundaries(builder.to_string())
    if actual != expected {
      failed += 1
      if failures.length() < 12 {
        failures.push(
          "case \{count}: \{row}; expected \{@debug.to_string(expected)}, actual \{@debug.to_string(actual)}",
        )
      }
    }
  }
  if failed > 0 {
    failures.push("\{failed} / \{count} cases failed")
  }
  (count, failures)
}
