///|
fn main {
  let text = "aaa bb bb ccccc"
  for algorithm in [@ml.WrapAlgorithm::Greedy, @ml.WrapAlgorithm::Optimal] {
    for
      line in @ml.layout(
        text,
        @ml.LayoutStyle::new(6, wrap_algorithm=algorithm),
      ) {
      println("|\{line.aligned_text}|")
    }
  }
}
