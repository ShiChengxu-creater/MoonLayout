///|
/// Optional normalization before layout. Off preserves input byte coordinates.
pub(all) enum Normalization {
  Off
  NFC
  NFKC
} derive(Eq, Debug)

///|
pub extend Normalization with Eq::{equal, not_equal}

///|
pub extend Normalization with Debug::{to_repr}

///|
/// Auto determines each paragraph's direction from its first strong character.
pub(all) enum Direction {
  Auto
  LTR
  RTL
} derive(Eq, Debug)

///|
pub extend Direction with Eq::{equal, not_equal}

///|
pub extend Direction with Debug::{to_repr}

///|
/// Line.source/start/end address logical_text, never the pre-normalized input.
/// Line.text remains logical; aligned_text is visual when bidi is enabled.
pub struct LayoutResult {
  original_text : String
  logical_text : String
  lines : Array[@wrap.Line]
} derive(Eq, Debug)

///|
pub extend LayoutResult with Eq::{equal, not_equal}

///|
pub extend LayoutResult with Debug::{to_repr}

///|
fn normalize(text : String, form : Normalization) -> String {
  match form {
    Off => text
    NFC => @normalization.nfc(text)
    NFKC => @normalization.nfkc(text)
  }
}

///|
/// Compose pinned normalization/BiDi primitives with logical wrapping. BiDi levels
/// are resolved over entire paragraphs, then reordered separately for each line.
/// This produces terminal cells, not shaped Arabic glyphs or font rendering.
pub fn layout(
  text : String,
  style : @layout.LayoutStyle,
  normalization? : Normalization = Off,
  bidi? : Bool = false,
  direction? : Direction = Auto,
) -> LayoutResult {
  let logical_text = normalize(text, normalization)
  let lines = @layout.layout(logical_text, style)
  {
    original_text: text,
    logical_text,
    lines: if bidi {
      visual_lines(lines, style, direction)
    } else {
      lines
    },
  }
}

///|
fn process(text : String, direction : Direction) -> @bidi.BidiParagraph {
  match direction {
    Auto => @bidi.process(text)
    LTR => @bidi.process(text, direction=@bidi.LTR)
    RTL => @bidi.process(text, direction=@bidi.RTL)
  }
}

///|
fn visual_lines(
  lines : Array[@wrap.Line],
  style : @layout.LayoutStyle,
  direction : Direction,
) -> Array[@wrap.Line] {
  let visual = []
  let mut first = 0
  while first < lines.length() {
    let b = StringBuilder()
    let mut end = first
    while end < lines.length() {
      b.write_string(lines[end].source)
      let paragraph_end = lines[end].source
        .iter()
        .any(fn(c) { @bidi.bidi_class(c) == @bidi.B })
      end += 1
      if paragraph_end {
        break
      }
    }
    let para = process(b.to_string(), direction)
    let mut scalar = 0
    for i = first; i < end; i = i + 1 {
      let line = lines[i]
      let text = reorder_line(line, para, scalar)
      scalar += line.source.iter().count()
      visual.push({
        ..line,
        text,
        aligned_text: text,
        width: @wrap.display_width(text, ambiguous_wide=style.ambiguous_wide),
      })
    }
    first = end
  }
  let width = if style.max_width > 0 { style.max_width } else { 1 }
  let aligned = @align.align_lines(visual, width, style.alignment)
  lines.mapi(fn(i, line) {
    {
      ..line,
      aligned_text: aligned[i],
      width: @wrap.display_width(
        aligned[i],
        ambiguous_wide=style.ambiguous_wide,
      ),
    }
  })
}

///|
// Retain source paragraph levels while matching display graphemes after tab/glue
// expansion. Reorder whole graphemes so combining marks/ZWJ sequences stay intact.
fn reorder_line(
  line : @wrap.Line,
  para : @bidi.BidiParagraph,
  scalar_start : Int,
) -> String {
  let raw = @grapheme.grapheme_iter(line.source)
    .map(fn(g) { g.to_owned() })
    .to_array()
  let offsets = []
  let mut scalar = scalar_start
  for g in raw {
    offsets.push(scalar)
    scalar += g.iter().count()
  }
  let display = @grapheme.grapheme_iter(line.text)
    .map(fn(g) { g.to_owned() })
    .to_array()
  let levels = []
  let classes = []
  let chars = []
  let mut cursor = 0
  let mut previous = para.base_level
  for g in display {
    let mut level = previous
    if g == " " {
      if cursor < raw.length() && (raw[cursor] == " " || raw[cursor] == "\t") {
        level = para.levels[offsets[cursor]]
        cursor += 1
      }
    } else {
      while cursor < raw.length() && raw[cursor] != g {
        cursor += 1
      }
      if cursor < raw.length() {
        level = para.levels[offsets[cursor]]
        cursor += 1
      }
    }
    previous = level
    let c = g.iter().to_array()[0]
    chars.push(c)
    classes.push(@bidi.bidi_class(c))
    levels.push(level)
  }
  // UAX #9 L1 is line-specific; the dependency already resolved other rules.
  for i = levels.length() - 1; i >= 0; i = i - 1 {
    match classes[i] {
      WS | S | B | LRI | RLI | FSI | PDI => levels[i] = para.base_level
      LRE | RLE | LRO | RLO | PDF | BN => ()
      _ => break
    }
  }
  let view : @bidi.BidiParagraph = {
    chars,
    levels,
    original_classes: classes,
    resolved_classes: classes,
    base_level: para.base_level,
  }
  let result = StringBuilder()
  for i in @bidi.reorder(view) {
    if classes[i].is_isolate_initiator() || classes[i] == @bidi.PDI {
      continue
    }
    for c in display[i].iter() {
      result.write_char(@bidi.get_mirrored(c, levels[i]))
    }
  }
  result.to_string()
}

///|
/// Compose normalization, logical hyphenation and optional visual reordering.
pub fn[H : @hyphen.Hyphenator] layout_hyphenated(
  text : String,
  style : @layout.LayoutStyle,
  hyphenator : H,
  normalization? : Normalization = Off,
  bidi? : Bool = false,
  direction? : Direction = Auto,
) -> LayoutResult {
  let logical_text = normalize(text, normalization)
  let lines = @layout.layout_hyphenated(logical_text, style, hyphenator)
  {
    original_text: text,
    logical_text,
    lines: if bidi {
      visual_lines(lines, style, direction)
    } else {
      lines
    },
  }
}
