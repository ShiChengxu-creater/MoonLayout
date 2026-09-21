///|
/// A scalar view with explicit UTF-8 byte and UTF-16 string offsets.
pub struct Text {
  chars : Array[Int]
  bytes : Array[Int]
  units : Array[Int]
}

///|
/// Decode once; offsets include the terminal boundary.
pub fn scan(s : String) -> Text {
  let chars = []
  let bytes = [0]
  let units = [0]
  let mut b = 0
  let mut u = 0
  for c in s.iter() {
    let cp = c.to_int()
    chars.push(cp)
    b += utf8_length(cp)
    u += c.utf16_len()
    bytes.push(b)
    units.push(u)
  }
  { chars, bytes, units }
}

///|
/// UTF-8 width of a Unicode scalar.
pub fn utf8_length(cp : Int) -> Int {
  if cp < 0x80 {
    1
  } else if cp < 0x800 {
    2
  } else if cp < 0x10000 {
    3
  } else {
    4
  }
}

///|
/// UTF-8 byte length, independent of the backend string representation.
pub fn byte_length(s : String) -> Int {
  s.iter().fold(init=0, fn(n, c) { n + utf8_length(c.to_int()) })
}
