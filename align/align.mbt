///|
/// Horizontal alignment in monospace display columns.
pub(all) enum Alignment {
  Left
  Right
  Center
  Justify
} derive(Eq, Debug)

///|
pub extend Alignment with Eq::{not_equal, equal}

///|
pub extend Alignment with Debug::{to_repr}

///|
fn cjk(s : String) -> Bool {
  match s.iter().next() {
    None => false
    Some(c) =>
      match @data.line_break(c.to_int()) {
        ID | CJ | JL | JV | JT | H2 | H3 => true
        _ => false
      }
  }
}

///|
fn justify(text : String, extra : Int) -> String {
  let gs = @grapheme.grapheme_iter(text).map(fn(g) { g.to_owned() }).to_array()
  let legal = @linebreak.line_break_opportunities(text)
  let slots : Array[Int] = []
  let mut byte = 0
  let mut content_seen = false
  for i = 0; i + 1 < gs.length(); i = i + 1 {
    byte += @text.byte_length(gs[i])
    if gs[i] != " " {
      content_seen = true
    }
    let space_gap = content_seen && gs[i] == " " && gs[i + 1] != " "
    let cjk_gap = cjk(gs[i]) &&
      cjk(gs[i + 1]) &&
      (match legal.binary_search(byte) {
        Ok(_) => true
        Err(_) => false
      })
    if space_gap || cjk_gap {
      slots.push(i)
    }
  }
  if slots.is_empty() {
    return text + " ".repeat(extra)
  }
  let each = extra / slots.length()
  let remainder = extra % slots.length()
  let builder = StringBuilder()
  let mut slot = 0
  for i, g in gs {
    builder.write_string(g)
    if slot < slots.length() && slots[slot] == i {
      builder.write_string(
        " ".repeat(each + (if slot < remainder { 1 } else { 0 })),
      )
      slot += 1
    }
  }
  builder.to_string()
}

///|
/// Pad each line to width without truncating overflow. Center puts an odd extra
/// space on the right. Justify stretches inter-word spaces or permitted CJK
/// grapheme gaps; final/Hard/End lines and lines with no slots are left-aligned.
/// Source ranges are untouched. All measurements respect each line's width mode.
pub fn align_lines(
  lines : Array[@wrap.Line],
  width : Int,
  alignment : Alignment,
) -> Array[String] {
  let result = []
  for i, line in lines {
    let text = line.text.trim_end(chars=" \t").to_owned()
    let actual = @wrap.display_width(text, ambiguous_wide=line.ambiguous_wide)
    let extra = if width > actual { width - actual } else { 0 }
    let value = match alignment {
      Left => text + " ".repeat(extra)
      Right => " ".repeat(extra) + text
      Center => " ".repeat(extra / 2) + text + " ".repeat(extra - extra / 2)
      Justify =>
        if i + 1 == lines.length() ||
          line.break_kind == @wrap.Hard ||
          line.break_kind == @wrap.End ||
          extra == 0 {
          text + " ".repeat(extra)
        } else {
          justify(text, extra)
        }
    }
    result.push(value)
  }
  result
}
