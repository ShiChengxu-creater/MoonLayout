///|
struct Case {
  text : String
  width : Int
  greedy : Array[String]
  breaks : Array[Int]
  nfc : String
  nfkc : String
} derive(ToJson)

///|
fn main {
  for
    s in [
      "hello world again", "aaa bb bb ccccc", "abcdefghi", "one two three four",
      "你好世界", "a\u{301}b", "e\u{301} Ａ ﬁ", "a\r\nb", "a  b c", "a\tb",
      "👩‍🔬 🇨🇳", "(abc) 123", "a\u{00A0}b", "שלום 123", "각가",
    ] {
    let result : Case = {
      text: s,
      width: 5,
      greedy: @ml.wrap(s, 5).map(fn(l) { l.text }),
      breaks: @ml.line_break_opportunities(s),
      nfc: @normalization.nfc(s),
      nfkc: @normalization.nfkc(s),
    }
    println(ToJson::to_json(result).stringify())
  }
}
