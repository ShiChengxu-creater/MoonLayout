///|
fn corpus(repeats : Int) -> String {
  "MoonLayout measures Unicode 段落 and emoji 👩‍🔬. ".repeat(repeats)
}

///|
test "linebreak 4K" (b : @bench.T) {
  let s = corpus(64)
  b.bench(fn() { b.keep(@ml.line_break_opportunities(s)) })
}

///|
test "word boundaries 4K" (b : @bench.T) {
  let s = corpus(64)
  b.bench(fn() { b.keep(@ml.word_boundaries(s)) })
}

///|
test "sentence boundaries 4K" (b : @bench.T) {
  let s = corpus(64)
  b.bench(fn() { b.keep(@ml.sentence_boundaries(s)) })
}

///|
test "greedy 4K width 80" (b : @bench.T) {
  let s = corpus(64)
  b.bench(fn() { b.keep(@ml.wrap(s, 80)) })
}

///|
test "optimal 4K width 80" (b : @bench.T) {
  let s = corpus(64)
  b.bench(fn() { b.keep(@ml.optimal_wrap(s, 80)) })
}

///|
test "justify 4K width 80" (b : @bench.T) {
  let lines = @ml.wrap(corpus(64), 80)
  b.bench(fn() { b.keep(@ml.align_lines(lines, 80, Justify)) })
}

///|
test "greedy large 64K width 80" (b : @bench.T) {
  let s = corpus(1024)
  b.bench(fn() { b.keep(@ml.wrap(s, 80)) })
}

///|
test "optimal large 64K width 80" (b : @bench.T) {
  let s = corpus(1024)
  b.bench(fn() { b.keep(@ml.optimal_wrap(s, 80)) })
}

///|
test "English hyphenation reused trie" (b : @bench.T) {
  let h = @ml.Liang::english()
  b.bench(fn() { b.keep(h.positions("representation")) })
}
