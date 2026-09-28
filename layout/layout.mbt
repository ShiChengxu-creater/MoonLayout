///|
pub using @align {type Alignment}

///|
pub using @wrap {
  type Line,
  type BreakKind,
  type WrapAlgorithm,
  type BreakPolicy,
  type OptimalOptions,
}

///|
/// Logical paragraph layout configuration. Optional integrations live in their own package.
pub(all) struct LayoutStyle {
  max_width : Int
  alignment : Alignment
  ambiguous_wide : Bool
  wrap_algorithm : WrapAlgorithm
  break_policy : BreakPolicy
  tab_width : Int
  optimal : OptimalOptions
} derive(Eq, Debug)

///|
pub extend LayoutStyle with Eq::{not_equal, equal}

///|
pub extend LayoutStyle with Debug::{to_repr}

///|
/// Construct a layout style (greedy by default). Nonpositive widths normalize to one column.
pub fn LayoutStyle::new(
  max_width : Int,
  alignment? : Alignment = Left,
  ambiguous_wide? : Bool = false,
  wrap_algorithm? : WrapAlgorithm = Greedy,
  break_policy? : BreakPolicy = Unicode,
  tab_width? : Int = 4,
  optimal? : OptimalOptions = OptimalOptions::new(),
) -> LayoutStyle {
  {
    max_width,
    alignment,
    ambiguous_wide,
    wrap_algorithm,
    break_policy,
    tab_width,
    optimal,
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
    Optimal =>
      @wrap.optimal_wrap(text, style.max_width, opts~, optimal=style.optimal)
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
