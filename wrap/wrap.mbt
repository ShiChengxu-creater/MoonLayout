///|
fn hard_cluster(s : String) -> Bool {
  s
  .iter()
  .any(fn(c) {
    match @data.line_break(c.to_int()) {
      BK | CR | LF | NL => true
      _ => false
    }
  })
}

///|
fn trailing_space(s : String) -> Bool {
  s == " " || s == "\t"
}

///|
fn cluster_width(
  s : String,
  column : Int,
  ambiguous_wide : Bool,
  tab_width : Int,
) -> Int {
  if s == "\t" {
    tab_width - column % tab_width
  } else if hard_cluster(s) {
    0
  } else {
    @width.str_width(s[:], cjk=ambiguous_wide)
  }
}

///|
/// Monospace cell width: sum the dependency's width per extended grapheme.
/// Tabs advance to tab stops; hard-break clusters have zero width. This function
/// does not perform font shaping or cross-grapheme ligature measurements.
pub fn display_width(
  s : String,
  ambiguous_wide? : Bool = false,
  tab_width? : Int = 4,
) -> Int {
  let tab = if tab_width > 0 { tab_width } else { 1 }
  let mut column = 0
  for g in @grapheme.grapheme_iter(s) {
    column += cluster_width(g.to_owned(), column, ambiguous_wide, tab)
  }
  column
}

///|
fn make_line(
  s : String,
  gs : Array[String],
  bytes : Array[Int],
  units : Array[Int],
  start : Int,
  end : Int,
  kind : BreakKind,
  opts : WrapOptions,
) -> Line {
  let mut visible_end = end
  if kind == Hard {
    visible_end -= 1
  }
  while visible_end > start && trailing_space(gs[visible_end - 1]) {
    visible_end -= 1
  }
  let builder = StringBuilder()
  let mut width = 0
  let tab = if opts.tab_width > 0 { opts.tab_width } else { 1 }
  for i = start; i < visible_end; i = i + 1 {
    let w = cluster_width(gs[i], width, opts.ambiguous_wide, tab)
    if gs[i] == "\t" {
      builder.write_string(" ".repeat(w))
    } else {
      builder.write_string(gs[i])
    }
    width += w
  }
  let text = builder.to_string()
  {
    start: bytes[start],
    end: bytes[end],
    source: s[units[start]:units[end]].to_owned(),
    text,
    width,
    break_kind: kind,
    aligned_text: text,
    ambiguous_wide: opts.ambiguous_wide,
  }
}

///|
/// Greedy wrapping with lossless source spans. Trailing ASCII spaces/tabs and
/// hard-break characters are absent from display text but remain in source.
/// Empty input returns []; nonpositive widths normalize to 1. An indivisible
/// grapheme wider than the limit occupies its own line without being split.
pub fn wrap(
  s : String,
  max_width : Int,
  opts? : WrapOptions = WrapOptions::new(),
) -> Array[Line] {
  if s.is_empty() {
    return []
  }
  let limit = if max_width > 0 { max_width } else { 1 }
  let gs = @grapheme.grapheme_iter(s).map(fn(g) { g.to_owned() }).to_array()
  let bytes = [0]
  let units = [0]
  for g in gs {
    bytes.push(bytes[bytes.length() - 1] + @text.byte_length(g))
    units.push(units[units.length() - 1] + g.length())
  }
  let unicode = @linebreak.line_break_opportunities(s)
  let preference = match opts.break_policy {
    Word => @segment.word_boundaries(s)
    Sentence => @segment.sentence_boundaries(s)
    _ => []
  }
  let allowed = Array::make(gs.length() + 1, false)
  for i = 1; i <= gs.length(); i = i + 1 {
    let base = match unicode.binary_search(bytes[i]) {
      Ok(_) => true
      Err(_) => false
    }
    let preferred = match preference.binary_search(bytes[i]) {
      Ok(_) => true
      Err(_) => false
    }
    allowed[i] = match opts.break_policy {
      Grapheme => true
      Unicode => base
      Word | Sentence => base && preferred
    }
  }
  let tab = if opts.tab_width > 0 { opts.tab_width } else { 1 }
  let lines = []
  let mut start = 0
  while start < gs.length() {
    let mut i = start
    let mut width = 0
    let mut visible_width = 0
    let mut last_break = start
    let mut emitted = false
    while i < gs.length() {
      if hard_cluster(gs[i]) {
        lines.push(make_line(s, gs, bytes, units, start, i + 1, Hard, opts))
        start = i + 1
        emitted = true
        break
      }
      let w = cluster_width(gs[i], width, opts.ambiguous_wide, tab)
      let candidate = if trailing_space(gs[i]) {
        visible_width
      } else {
        width + w
      }
      if candidate > limit && i > start {
        let end = if last_break > start { last_break } else { i }
        let kind = if last_break > start { Soft } else { Forced }
        lines.push(make_line(s, gs, bytes, units, start, end, kind, opts))
        start = end
        emitted = true
        break
      }
      width += w
      visible_width = candidate
      i += 1
      if allowed[i] {
        last_break = i
      }
    }
    if !emitted {
      lines.push(make_line(s, gs, bytes, units, start, gs.length(), End, opts))
      start = gs.length()
    }
  }
  if hard_cluster(gs[gs.length() - 1]) {
    lines.push(
      make_line(s, gs, bytes, units, gs.length(), gs.length(), End, opts),
    )
  }
  lines
}
