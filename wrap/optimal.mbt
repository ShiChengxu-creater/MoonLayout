///|
/// Per internal ASCII space: maximum added cells (stretch) and removed cells
/// (shrink, capped at one). Negative settings become zero. Penalties are capped
/// to keep costs finite. This is a simplified paragraph optimizer, not TeX.
pub(all) struct OptimalOptions {
  stretch : Int
  shrink : Int
  line_penalty : Int
  hyphen_penalty : Int
} derive(Eq, Debug)

///|
pub extend OptimalOptions with Eq::{equal, not_equal}

///|
pub extend OptimalOptions with Debug::{to_repr}

///|
/// Defaults minimize squared nonfinal slack without changing space widths.
pub fn OptimalOptions::new(
  stretch? : Int = 0,
  shrink? : Int = 0,
  line_penalty? : Int = 1,
  hyphen_penalty? : Int = 50,
) -> OptimalOptions {
  { stretch, shrink, line_penalty, hyphen_penalty, }
}

///|
fn bounded(value : Int, maximum : Int) -> Int {
  if value < 0 {
    0
  } else if value > maximum {
    maximum
  } else {
    value
  }
}

///|
// Glue is restricted to internal ASCII spaces. Tabs retain tab-stop semantics.
fn adjust_glue(line : Line, limit : Int, optimal : OptimalOptions) -> Line {
  let chars = line.text.iter().to_array()
  let slots = chars.filter(fn(c) { c == ' ' }).length()
  if slots == 0 {
    return line
  }
  let delta = limit - line.width
  let capacity = if delta < 0 {
    slots * bounded(optimal.shrink, 1)
  } else {
    slots * bounded(optimal.stretch, 1024)
  }
  if delta == 0 ||
    delta.abs() > capacity ||
    (delta > 0 && (line.break_kind == End || line.break_kind == Hard)) {
    return line
  }
  let b = StringBuilder()
  let mut remaining = delta
  let mut left = slots
  for c in chars {
    if c == ' ' {
      let change = if remaining > 0 {
        (remaining + left - 1) / left
      } else {
        remaining / left
      }
      b.write_string(" ".repeat(1 + change))
      remaining -= change
      left -= 1
    } else {
      b.write_char(c)
    }
  }
  let text = b.to_string()
  { ..line, text, aligned_text: text, width: limit, }
}

///|
/// Minimize paragraph cost over grapheme boundaries with dynamic programming.
/// Natural breaks dominate emergency splits. Hard breaks are mandatory. Costs
/// combine squared slack, cubic glue adjustment and configurable line penalties;
/// the final line is ragged. Source spans always refer to the unchanged input.
pub fn optimal_wrap(
  s : String,
  max_width : Int,
  opts? : WrapOptions = WrapOptions::new(),
  optimal? : OptimalOptions = OptimalOptions::new(),
) -> Array[Line] {
  optimal_points(s, max_width, opts, optimal, Map([]))
}

///|
fn optimal_points(
  s : String,
  max_width : Int,
  opts : WrapOptions,
  optimal : OptimalOptions,
  points : Map[Int, Bool],
) -> Array[Line] {
  if s.is_empty() {
    return []
  }
  let limit = if max_width > 0 { max_width } else { 1 }
  let gs = @grapheme.grapheme_iter(s).map(fn(g) { g.to_owned() }).to_array()
  let n = gs.length()
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
  let allowed = Array::make(n + 1, false)
  for i = 1; i <= n; i = i + 1 {
    let base = unicode.binary_search(bytes[i]) is Ok(_)
    allowed[i] = match opts.break_policy {
      Grapheme => true
      Unicode => base
      Word | Sentence => base && preference.binary_search(bytes[i]) is Ok(_)
    }
  }
  let cost = Array::make(n + 1, 1.0e100)
  let emergencies = Array::make(n + 1, 0x3FFFFFFF)
  emergencies[n] = 0
  let next = Array::make(n, n)
  let kinds = Array::make(n, End)
  cost[n] = 0.0
  let tab = if opts.tab_width > 0 { opts.tab_width } else { 1 }
  for start = n - 1; start >= 0; start = start - 1 {
    let mut width = 0
    let mut visible = 0
    let mut spaces = 0
    let mut visible_spaces = 0
    for i = start; i < n; i = i + 1 {
      let hard = hard_cluster(gs[i])
      if !hard {
        width += cluster_width(gs[i], width, opts.ambiguous_wide, tab)
        if gs[i] == " " {
          spaces += 1
        }
        if !trailing_space(gs[i]) {
          visible = width
          visible_spaces = spaces
        }
      }
      let end = i + 1
      let shrink = visible_spaces * bounded(optimal.shrink, 1)
      if visible - shrink > limit && i > start {
        break
      }
      let kind = if hard {
        Hard
      } else if end == n {
        End
      } else if allowed[end] {
        Soft
      } else if points.contains(bytes[end]) && visible + 1 - shrink <= limit {
        Hyphenated
      } else {
        Forced
      }
      // Do not manufacture a line of just the whitespace following a word.
      let whitespace_split = end < n && trailing_space(gs[end])
      if !whitespace_split || hard || end == n {
        let shown = visible + (if kind == Hyphenated { 1 } else { 0 })
        let delta = limit.to_double() - shown.to_double()
        let stretch = visible_spaces * bounded(optimal.stretch, 1024)
        let capacity = if delta < 0.0 { shrink } else { stretch }
        let badness = if (hard || end == n) && delta >= 0.0 {
          0.0
        } else if capacity > 0 && delta.abs() <= capacity.to_double() {
          let ratio = delta.abs() / capacity.to_double()
          100.0 * ratio * ratio * ratio
        } else {
          delta * delta
        }
        let emergency = emergencies[end] + (if kind == Forced { 1 } else { 0 })
        let hyphen_cost = if kind == Hyphenated {
          bounded(optimal.hyphen_penalty, 1000000).to_double()
        } else {
          0.0
        }
        let score = cost[end] +
          badness +
          hyphen_cost +
          bounded(optimal.line_penalty, 1000000).to_double()
        if emergency < emergencies[start] ||
          (emergency == emergencies[start] && score <= cost[start]) {
          emergencies[start] = emergency
          cost[start] = score
          next[start] = end
          kinds[start] = kind
        }
      }
      if hard {
        break
      }
    }
    // An overwide grapheme is indivisible; always guarantee forward progress.
    if cost[start] == 1.0e100 {
      next[start] = start + 1
      kinds[start] = if start + 1 == n { End } else { Forced }
      cost[start] = cost[start + 1]
      emergencies[start] = emergencies[start + 1] + 1
    }
  }
  let result = []
  let mut start = 0
  while start < n {
    let end = next[start]
    result.push(
      adjust_glue(
        make_line(s, gs, bytes, units, start, end, kinds[start], opts),
        limit,
        optimal,
      ),
    )
    start = end
  }
  if hard_cluster(gs[n - 1]) {
    result.push(make_line(s, gs, bytes, units, n, n, End, opts))
  }
  result
}
