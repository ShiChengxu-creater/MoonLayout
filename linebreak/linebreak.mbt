///|
// Unicode 17.0.0 UAX #14 rev. 55. Rules are applied in normative order.
priv struct Token {
  cls : @data.LineBreak
  cp : Int
  start : Int
  zwj : Bool
}

///|
fn hard(c : @data.LineBreak) -> Bool {
  match c {
    BK | CR | LF | NL => true
    _ => false
  }
}

///|
fn alphabetic(c : @data.LineBreak) -> Bool {
  match c {
    AL | HL => true
    _ => false
  }
}

///|
fn hangul(c : @data.LineBreak) -> Bool {
  match c {
    JL | JV | JT | H2 | H3 => true
    _ => false
  }
}

///|
fn east_asian(cp : Int) -> Bool {
  match @data.east_asian_width(cp) {
    F | W | H => true
    _ => false
  }
}

///|
fn aksara(t : Token) -> Bool {
  t.cls == AK || t.cls == AS || t.cp == 0x25CC
}

///|
fn resolve(cp : Int) -> @data.LineBreak {
  match @data.line_break(cp) {
    AI | SG | XX => AL
    CJ => NS
    SA =>
      match @data.general_category(cp) {
        Mn | Mc => CM
        _ => AL
      }
    c => c
  }
}

///|
fn tokens(text : @text.Text) -> Array[Token] {
  let result : Array[Token] = []
  for i, cp in text.chars {
    let cls = resolve(cp)
    if cls == CM || cls == ZWJ {
      if !result.is_empty() {
        let last = result[result.length() - 1]
        if !hard(last.cls) && last.cls != SP && last.cls != ZW {
          // LB9: remove attached marks for all subsequent context rules.
          result[result.length() - 1] = { ..last, zwj: cls == ZWJ, }
          continue
        }
      }
      // LB10 substitutes all properties of U+0041, not just its class.
      result.push({ cls: AL, cp: 0x41, start: i, zwj: cls == ZWJ, })
    } else {
      result.push({ cls, cp, start: i, zwj: false, })
    }
  }
  result
}

///|
fn break_before(ts : Array[Token], i : Int, regional_count : Int) -> Bool {
  let left = ts[i - 1]
  let right = ts[i]
  let a = left.cls
  let b = right.cls
  // LB4–LB8a: mandatory boundaries, spaces, ZW and original ZWJ.
  if a == BK {
    return true
  }
  if a == CR && b == LF {
    return false
  }
  if hard(a) {
    return true
  }
  if hard(b) || b == SP || b == ZW {
    return false
  }
  let mut p = i - 1
  while p >= 0 && ts[p].cls == SP {
    p -= 1
  }
  if p >= 0 && ts[p].cls == ZW {
    return true
  }
  if left.zwj {
    return false
  }
  // LB9/10 were resolved while building tokens.
  if a == WJ || b == WJ {
    return false
  } // LB11
  if a == GL {
    return false
  } // LB12
  if b == GL && a != SP && a != BA && a != HY && a != HH {
    return false
  } // LB12a
  if b == CL || b == CP || b == EX || b == SY {
    return false
  } // LB13
  if p >= 0 && ts[p].cls == OP {
    return false
  } // LB14
  // LB15a: initial quotation at the beginning of a phrase, with SP*.
  if p >= 0 && ts[p].cls == QU && @data.general_category(ts[p].cp) == Pi {
    if p == 0 {
      return false
    }
    let before = ts[p - 1].cls
    if hard(before) ||
      before == OP ||
      before == QU ||
      before == GL ||
      before == SP ||
      before == ZW {
      return false
    }
  }
  // LB15b: final quotation before a closing context.
  if b == QU && @data.general_category(right.cp) == Pf {
    if i + 1 == ts.length() {
      return false
    }
    let after = ts[i + 1].cls
    if hard(after) ||
      after == SP ||
      after == GL ||
      after == WJ ||
      after == CL ||
      after == QU ||
      after == CP ||
      after == EX ||
      after == IS ||
      after == SY ||
      after == ZW {
      return false
    }
  }
  if a == SP && b == IS && i + 1 < ts.length() && ts[i + 1].cls == NU {
    return true
  } // LB15c
  if b == IS {
    return false
  } // LB15d
  if p >= 0 && (ts[p].cls == CL || ts[p].cls == CP) && b == NS {
    return false
  } // LB16
  if p >= 0 && ts[p].cls == B2 && b == B2 {
    return false
  } // LB17
  if a == SP {
    return true
  } // LB18
  if b == QU && @data.general_category(right.cp) != Pi {
    return false
  } // LB19
  if a == QU && @data.general_category(left.cp) != Pf {
    return false
  }
  // LB19a: opening/final quote must be surrounded by East Asian characters.
  if b == QU &&
    (!east_asian(left.cp) || i + 1 == ts.length() || !east_asian(ts[i + 1].cp)) {
    return false
  }
  if a == QU && (!east_asian(right.cp) || i == 1 || !east_asian(ts[i - 2].cp)) {
    return false
  }
  if a == CB || b == CB {
    return true
  } // LB20
  if (a == HY || a == HH) && alphabetic(b) {
    if i == 1 {
      return false
    }
    let before = ts[i - 2].cls
    if hard(before) ||
      before == SP ||
      before == ZW ||
      before == CB ||
      before == GL {
      return false
    }
  } // LB20a
  if b == BA || b == HH || b == HY || b == NS || a == BB {
    return false
  } // LB21
  if (a == HY || a == HH) && i >= 2 && ts[i - 2].cls == HL && b != HL {
    return false
  } // LB21a
  if a == SY && b == HL {
    return false
  } // LB21b
  if b == IN {
    return false
  } // LB22
  if (alphabetic(a) && b == NU) || (a == NU && alphabetic(b)) {
    return false
  } // LB23
  if (a == PR && (b == ID || b == EB || b == EM)) ||
    ((a == ID || a == EB || a == EM) && b == PO) {
    return false
  } // LB23a
  if ((a == PR || a == PO) && alphabetic(b)) ||
    (alphabetic(a) && (b == PR || b == PO)) {
    return false
  } // LB24
  // LB25: numeric contexts. Only SY/IS may intervene after the last NU.
  if b == PO || b == PR || b == NU {
    let mut n = i - 1
    if (b == PO || b == PR) && (a == CL || a == CP) {
      n -= 1
    }
    while n >= 0 && (ts[n].cls == SY || ts[n].cls == IS) {
      n -= 1
    }
    if n >= 0 && ts[n].cls == NU {
      return false
    }
  }
  if a == PO || a == PR {
    if b == NU {
      return false
    }
    if b == OP && i + 1 < ts.length() {
      if ts[i + 1].cls == NU {
        return false
      }
      if ts[i + 1].cls == IS && i + 2 < ts.length() && ts[i + 2].cls == NU {
        return false
      }
    }
  }
  if (a == HY || a == IS) && b == NU {
    return false
  }
  // LB26–27: Hangul syllables and numeric affixes.
  if a == JL && (b == JL || b == JV || b == H2 || b == H3) {
    return false
  }
  if (a == JV || a == H2) && (b == JV || b == JT) {
    return false
  }
  if (a == JT || a == H3) && b == JT {
    return false
  }
  if (hangul(a) && b == PO) || (a == PR && hangul(b)) {
    return false
  }
  if alphabetic(a) && alphabetic(b) {
    return false
  } // LB28
  // LB28a: Brahmic orthographic syllables, including dotted circle.
  if a == AP && aksara(right) {
    return false
  }
  if aksara(left) && (b == VF || b == VI) {
    return false
  }
  if a == VI && i >= 2 && aksara(ts[i - 2]) && (b == AK || right.cp == 0x25CC) {
    return false
  }
  if aksara(left) && aksara(right) && i + 1 < ts.length() && ts[i + 1].cls == VF {
    return false
  }
  if a == IS && alphabetic(b) {
    return false
  } // LB29
  if (alphabetic(a) || a == NU) && b == OP && !east_asian(right.cp) {
    return false
  } // LB30
  if a == CP && !east_asian(left.cp) && (alphabetic(b) || b == NU) {
    return false
  }
  if a == RI && b == RI && regional_count % 2 == 1 {
    return false
  } // LB30a
  if b == EM &&
    (
      a == EB ||
      (
        @data.emoji_property(left.cp) == Extended_Pictographic &&
        @data.general_category(left.cp) == Cn
      )
    ) {
    return false
  } // LB30b
  true // LB31
}

///|
/// Default UAX #14 break opportunities as UTF-8 byte offsets. Includes end of
/// text, excludes start except for empty text (which returns [0]).
pub fn line_break_opportunities(s : String) -> Array[Int] {
  let text = @text.scan(s)
  let ts = tokens(text)
  let result = []
  let mut regional_count = 0
  for i = 1; i < ts.length(); i = i + 1 {
    if ts[i - 1].cls == RI {
      regional_count += 1
    } else {
      regional_count = 0
    }
    if break_before(ts, i, regional_count) {
      result.push(text.bytes[ts[i].start])
    }
  }
  result.push(text.bytes[text.bytes.length() - 1]) // LB3
  result
}

///|
/// Test a UTF-8 byte offset; invalid or interior byte positions return false.
pub fn is_breakable_at(s : String, byte_index : Int) -> Bool {
  if byte_index < 0 {
    return false
  }
  line_break_opportunities(s).contains(byte_index)
}
