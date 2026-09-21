///|
/// Reason a line ended. Forced is an emergency grapheme boundary; End is EOF.
pub(all) enum BreakKind {
  Soft
  Hard
  Forced
  End
} derive(Eq, Debug)

///|
/// Preferred boundaries. Word/Sentence intersect UAX #14; Grapheme allows every
/// grapheme boundary. Emergency splitting still applies when a unit is too long.
pub(all) enum BreakPolicy {
  Unicode
  Word
  Sentence
  Grapheme
} derive(Eq, Debug)

///|
/// Initial acceptance supports greedy wrapping only.
pub(all) enum WrapAlgorithm {
  Greedy
} derive(Eq, Debug)

///|
pub(all) struct WrapOptions {
  ambiguous_wide : Bool
  break_policy : BreakPolicy
  tab_width : Int
} derive(Eq, Debug)

///|
/// Nonpositive tab widths normalize to one column.
pub fn WrapOptions::new(
  ambiguous_wide? : Bool = false,
  break_policy? : BreakPolicy = Unicode,
  tab_width? : Int = 4,
) -> WrapOptions {
  {
    ambiguous_wide,
    break_policy,
    tab_width: if tab_width > 0 {
      tab_width
    } else {
      1
    },
  }
}

///|
/// Exact source range [start,end) in UTF-8 bytes, with a lossless source copy.
/// text is trimmed/expanded content; aligned_text is the final display string.
/// width measures aligned_text. Wrapping initially sets aligned_text = text.
pub(all) struct Line {
  start : Int
  end : Int
  source : String
  text : String
  width : Int
  break_kind : BreakKind
  aligned_text : String
  ambiguous_wide : Bool
} derive(Eq, Debug)
