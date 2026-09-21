///|
fn main {
  let input = "Hello, 世界! It's 3.14. Next sentence."
  for word in @ml.words(input) {
    println("word: \{word}")
  }
  for sentence in @ml.sentences(input) {
    println("sentence: \{sentence}")
  }
  for range in @ml.segments(input, Word) {
    println("word bytes: \{range.0}..\{range.1}")
  }
}
