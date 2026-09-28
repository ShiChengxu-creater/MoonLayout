///|
/// High-level paragraph layout facade.
pub using @layout {type LayoutStyle, layout}

///|
pub using @align {type Alignment, align_lines}

///|
pub using @wrap {
  type Line,
  type BreakKind,
  type WrapOptions,
  type OptimalOptions,
  type WrapAlgorithm,
  type BreakPolicy,
  wrap,
  optimal_wrap,
  display_width,
}

///|
pub using @segment {
  type SegmentKind,
  segments,
  words,
  sentences,
  word_boundaries,
  sentence_boundaries,
}

///|
pub using @linebreak {line_break_opportunities, is_breakable_at}
