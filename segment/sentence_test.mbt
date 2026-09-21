///|
test "valid/sentence abbreviations trailing space and paragraphs" {
  assert_eq(@segment.sentences("Hello! Next."), ["Hello! ", "Next."])
  assert_eq(@segment.sentences("e.g. this works. Next!"), [
    "e.g. this works. ", "Next!",
  ])
  assert_eq(@segment.sentences("a\r\nb"), ["a\r\n", "b"])
  assert_eq(@segment.segments("你好。再见！", @segment.Sentence), [
    (0, 9),
    (9, 18),
  ])
}

///|
test "edge/sentence empty and word ranges retain punctuation" {
  assert_eq(@segment.sentence_boundaries(""), [0])
  assert_eq(@segment.sentences(""), [])
  assert_eq(@segment.segments("Hi!", @segment.Word), [(0, 2), (2, 3)])
  assert_eq(@segment.sentences("..."), ["..."])
}
