///|
fn word_ignored(c : @data.WordBreak) -> Bool {
  match c {
    Extend | Format | ZWJ => true
    _ => false
  }
}

///|
fn word_newline(c : @data.WordBreak) -> Bool {
  match c {
    Newline | CR | LF => true
    _ => false
  }
}

///|
fn ah(c : @data.WordBreak) -> Bool {
  match c {
    ALetter | Hebrew_Letter => true
    _ => false
  }
}

///|
fn mid_letter(c : @data.WordBreak) -> Bool {
  match c {
    MidLetter | MidNumLet | Single_Quote => true
    _ => false
  }
}

///|
fn mid_number(c : @data.WordBreak) -> Bool {
  match c {
    MidNum | MidNumLet | Single_Quote => true
    _ => false
  }
}

///|
fn word_break_at(
  chars : Array[Int],
  classes : Array[@data.WordBreak],
  prev : Array[Int],
  next : Array[Int],
  i : Int,
  regional_count : Int,
) -> Bool {
  let raw_a = classes[i - 1]
  let b = classes[i]
  if raw_a == CR && b == LF {
    return false
  } // WB3
  if word_newline(raw_a) || word_newline(b) {
    return true
  } // WB3a/b
  if raw_a == ZWJ && @data.emoji_property(chars[i]) == Extended_Pictographic {
    return false
  } // WB3c
  if raw_a == WSegSpace && b == WSegSpace {
    return false
  } // WB3d
  if word_ignored(b) {
    return false
  } // WB4
  let j = prev[i]
  if j < 0 {
    return true
  }
  let a = classes[j]
  let h = prev[j]
  let k = next[i + 1]
  if ah(a) && ah(b) {
    return false
  } // WB5
  if ah(a) && mid_letter(b) && k < classes.length() && ah(classes[k]) {
    return false
  } // WB6
  if mid_letter(a) && ah(b) && h >= 0 && ah(classes[h]) {
    return false
  } // WB7
  if a == Hebrew_Letter && b == Single_Quote {
    return false
  } // WB7a
  if a == Hebrew_Letter &&
    b == Double_Quote &&
    k < classes.length() &&
    classes[k] == Hebrew_Letter {
    return false
  } // WB7b
  if a == Double_Quote &&
    b == Hebrew_Letter &&
    h >= 0 &&
    classes[h] == Hebrew_Letter {
    return false
  } // WB7c
  if a == Numeric && b == Numeric {
    return false
  } // WB8
  if (ah(a) && b == Numeric) || (a == Numeric && ah(b)) {
    return false
  } // WB9/10
  if mid_number(a) && b == Numeric && h >= 0 && classes[h] == Numeric {
    return false
  } // WB11
  if a == Numeric &&
    mid_number(b) &&
    k < classes.length() &&
    classes[k] == Numeric {
    return false
  } // WB12
  if a == Katakana && b == Katakana {
    return false
  } // WB13
  if (ah(a) || a == Numeric || a == Katakana || a == ExtendNumLet) &&
    b == ExtendNumLet {
    return false
  } // WB13a
  if a == ExtendNumLet && (ah(b) || b == Numeric || b == Katakana) {
    return false
  } // WB13b
  if a == Regional_Indicator &&
    b == Regional_Indicator &&
    regional_count % 2 == 1 {
    return false
  } // WB15/16
  true // WB999
}

///|
/// Unicode 17 UAX #29 default word boundaries, in UTF-8 bytes. Includes both
/// endpoints; an empty string has the single boundary [0].
pub fn word_boundaries(s : String) -> Array[Int] {
  let text = @text.scan(s)
  let classes = text.chars.map(@data.word_break)
  let n = classes.length()
  let prev = Array::make(n + 1, -1)
  let next = Array::make(n + 1, n)
  for i = 0; i < n; i = i + 1 {
    prev[i + 1] = if word_ignored(classes[i]) { prev[i] } else { i }
  }
  for i = n - 1; i >= 0; i = i - 1 {
    next[i] = if word_ignored(classes[i]) { next[i + 1] } else { i }
  }
  let result = [0]
  let mut regional_count = 0
  for i = 1; i < n; i = i + 1 {
    if classes[i - 1] == Regional_Indicator {
      regional_count += 1
    } else if !word_ignored(classes[i - 1]) {
      regional_count = 0
    }
    if word_break_at(text.chars, classes, prev, next, i, regional_count) {
      result.push(text.bytes[i])
    }
  }
  if n > 0 {
    result.push(text.bytes[n])
  }
  result
}

///|
fn word_content(cp : Int) -> Bool {
  match @data.general_category(cp) {
    Lu | Ll | Lt | Lm | Lo | Nd | Nl | No => true
    _ => false
  }
}

///|
/// Return word segments containing a letter or number. Whitespace, punctuation,
/// and emoji-only segments are omitted; use word_boundaries to retain all text.
pub fn words(s : String) -> Array[String] {
  boundary_strings(s, word_boundaries(s)).filter(fn(part) {
    part.iter().any(fn(c) { word_content(c.to_int()) })
  })
}
