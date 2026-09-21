///|
fn paragraph(c : @data.SentenceBreak) -> Bool {
  match c {
    Sep | CR | LF => true
    _ => false
  }
}

///|
fn terminal(c : @data.SentenceBreak) -> Bool {
  match c {
    STerm | ATerm => true
    _ => false
  }
}

///|
fn sentence_break_at(cs : Array[@data.SentenceBreak], i : Int) -> Bool {
  let a = cs[i - 1]
  let b = cs[i]
  if a == CR && b == LF {
    return false
  } // SB3
  if paragraph(a) {
    return true
  } // SB4
  // SB5 was applied during tokenization.
  if a == ATerm && b == Numeric {
    return false
  } // SB6
  if a == ATerm &&
    b == Upper &&
    i >= 2 &&
    (cs[i - 2] == Upper || cs[i - 2] == Lower) {
    return false
  } // SB7
  let mut p = i - 1
  while p >= 0 && cs[p] == Sp {
    p -= 1
  }
  while p >= 0 && cs[p] == Close {
    p -= 1
  }
  let after_terminal = p >= 0 && terminal(cs[p])
  if p >= 0 && cs[p] == ATerm { // SB8
    let mut q = i
    while q < cs.length() {
      let c = cs[q]
      if c == Lower {
        return false
      }
      if c == OLetter || c == Upper || paragraph(c) || terminal(c) {
        break
      }
      q += 1
    }
  }
  if after_terminal && (b == SContinue || terminal(b)) {
    return false
  } // SB8a
  let mut close = i - 1
  while close >= 0 && cs[close] == Close {
    close -= 1
  }
  if close >= 0 &&
    terminal(cs[close]) &&
    (b == Close || b == Sp || paragraph(b)) {
    return false
  } // SB9
  if after_terminal && (b == Sp || paragraph(b)) {
    return false
  } // SB10
  after_terminal // SB11, otherwise SB998
}

///|
/// Unicode 17 UAX #29 sentence boundaries as UTF-8 byte offsets. Includes both
/// endpoints. Separators and trailing spaces belong to the preceding sentence.
pub fn sentence_boundaries(s : String) -> Array[Int] {
  let text = @text.scan(s)
  let classes : Array[@data.SentenceBreak] = []
  let positions : Array[Int] = []
  for i, cp in text.chars {
    let c = @data.sentence_break(cp)
    if c == Extend || c == Format {
      if !classes.is_empty() && !paragraph(classes[classes.length() - 1]) {
        continue
      }
      classes.push(Other)
    } else {
      classes.push(c)
    }
    positions.push(text.bytes[i])
  }
  let result = [0]
  for i = 1; i < classes.length(); i = i + 1 {
    if sentence_break_at(classes, i) {
      result.push(positions[i])
    }
  }
  if !text.chars.is_empty() {
    result.push(text.bytes[text.chars.length()])
  }
  result
}

///|
/// Split sentences without dropping punctuation, whitespace or paragraph breaks.
pub fn sentences(s : String) -> Array[String] {
  boundary_strings(s, sentence_boundaries(s))
}

///|
/// Select the default Unicode boundary algorithm.
pub(all) enum SegmentKind {
  Word
  Sentence
} derive(Eq, Debug)

///|
/// All half-open UTF-8 byte ranges, including whitespace/punctuation segments.
pub fn segments(s : String, kind : SegmentKind) -> Array[(Int, Int)] {
  let boundaries = match kind {
    Word => word_boundaries(s)
    Sentence => sentence_boundaries(s)
  }
  let result = []
  for i = 1; i < boundaries.length(); i = i + 1 {
    result.push((boundaries[i - 1], boundaries[i]))
  }
  result
}
