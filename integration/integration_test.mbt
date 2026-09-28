///|
test "valid/normalization exposes logical coordinate space" {
  let result = @integration.layout(
    "e\u{301} Ａ",
    @layout.LayoutStyle::new(8),
    normalization=NFKC,
  )
  assert_eq(result.original_text, "e\u{301} Ａ")
  assert_eq(result.logical_text, "é A")
  assert_eq(result.lines[0].source, "é A")
  assert_eq(result.lines[0].end, 4)
  assert_eq(
    @integration.layout(
      "e\u{301}",
      @layout.LayoutStyle::new(8),
      normalization=NFC,
    ).logical_text,
    "é",
  )
}

///|
test "valid/bidi logical breaks visual output and combining marks" {
  let result = @integration.layout(
    "אבג דהו",
    @layout.LayoutStyle::new(3),
    bidi=true,
  )
  assert_eq(result.lines.map(fn(l) { l.source }).join(""), "אבג דהו")
  assert_eq(result.lines.map(fn(l) { l.text }), ["אבג", "דהו"])
  assert_eq(result.lines.map(fn(l) { l.aligned_text }), ["גבא", "והד"])
  let marks = @integration.layout(
    "ש\u{05B8}לום",
    @layout.LayoutStyle::new(10),
    bidi=true,
  )
  assert_true(marks.lines[0].aligned_text.contains("ש\u{05B8}"))
  assert_eq(
    @integration.layout("abc", @layout.LayoutStyle::new(3), bidi=true).lines[0].aligned_text,
    "abc",
  )
}

///|
test "edge/bidi paragraphs numbers tabs and blank lines" {
  let result = @integration.layout(
    "אבג 123\nabc\n",
    @layout.LayoutStyle::new(7),
    bidi=true,
  )
  assert_eq(result.lines[0].aligned_text, "123 גבא")
  assert_eq(result.lines[1].aligned_text, "abc    ")
  assert_eq(result.lines[2].aligned_text, "       ")
  assert_eq(
    @integration.layout("", @layout.LayoutStyle::new(2), bidi=true).lines,
    [],
  )
}

///|
test "valid/integration composes all final acceptance features" {
  let result = @integration.layout_hyphenated(
    "hyphenation אבג",
    @layout.LayoutStyle::new(7, wrap_algorithm=Optimal),
    @hyphen.Liang::english(),
    bidi=true,
    normalization=NFC,
  )
  assert_eq(result.lines.map(fn(l) { l.source }).join(""), result.logical_text)
  assert_true(result.lines.any(fn(l) { l.break_kind == @wrap.Hyphenated }))
  assert_true(result.lines.any(fn(l) { l.aligned_text.contains("גבא") }))
}

///|
test "valid/paragraph direction survives soft line boundaries" {
  // Neutral-only line retains the RTL paragraph base instead of defaulting LTR.
  let result = @integration.layout(
    "אבג !!! ???",
    @layout.LayoutStyle::new(7),
    bidi=true,
  )
  assert_eq(result.lines[0].aligned_text, "!!! גבא")
  assert_eq(result.lines[1].aligned_text, "???    ")
  let emoji = @integration.layout(
    "אב 👩‍🔬",
    @layout.LayoutStyle::new(10),
    bidi=true,
  )
  assert_true(emoji.lines[0].aligned_text.contains("👩‍🔬"))
}
