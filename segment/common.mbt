///|
fn boundary_strings(s : String, boundaries : Array[Int]) -> Array[String] {
  let text = @text.scan(s)
  let result = []
  let mut start_unit = 0
  let mut scalar = 0
  for i = 1; i < boundaries.length(); i = i + 1 {
    while text.bytes[scalar] < boundaries[i] {
      scalar += 1
    }
    result.push(s[start_unit:text.units[scalar]].to_owned())
    start_unit = text.units[scalar]
  }
  result
}
