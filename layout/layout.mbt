///|
pub using @align {type Alignment}

///|
pub using @wrap {
  type Line,
  type BreakKind,
  type WrapAlgorithm,
  type BreakPolicy,
}

///|
/// Complete initial-release layout configuration. Hyphenation and optimal
/// wrapping are intentionally deferred to the later release in goal.md.
pub(all) struct LayoutStyle {
  max_width : Int
  alignment : Alignment
  ambiguous_wide : Bool
  wrap_algorithm : WrapAlgorithm
  break_policy : BreakPolicy
  tab_width : Int
} derive(Eq, Debug)

///|
/// Construct a greedy style. Nonpositive widths normalize to one column.
pub fn LayoutStyle::new(
  max_width : Int,
  alignment? : Alignment = Left,
  ambiguous_wide? : Bool = false,
  wrap_algorithm? : WrapAlgorithm = Greedy,
  break_policy? : BreakPolicy = Unicode,
  tab_width? : Int = 4,
) -> LayoutStyle {
  {
    max_width,
    alignment,
    ambiguous_wide,
    wrap_algorithm,
    break_policy,
    tab_width,
  }
}

///|
/// Layout a logical paragraph into lines with source ranges and aligned text.
pub fn layout(text : String, style : LayoutStyle) -> Array[Line] {
  let opts = @wrap.WrapOptions::new(
    ambiguous_wide=style.ambiguous_wide,
    break_policy=style.break_policy,
    tab_width=style.tab_width,
  )
  let lines = match style.wrap_algorithm {
    Greedy => @wrap.wrap(text, style.max_width, opts~)
  }
  let width = if style.max_width > 0 { style.max_width } else { 1 }
  let aligned = @align.align_lines(lines, width, style.alignment)
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
