///|
/// Pluggable discretionary word breaks, expressed as UTF-8 byte offsets within
/// the supplied word. The wrapping layer validates and deduplicates positions.
pub(open) trait Hyphenator {
  fn positions(Self, String) -> Array[Int]
}

///|
struct Node {
  children : Map[Int, Int]
  weights : Array[Int]
}

///|
/// Immutable-after-construction Liang pattern trie for ASCII English words.
pub struct Liang {
  nodes : Array[Node]
  exceptions : Map[String, Array[Int]]
  left_min : Int
  right_min : Int
}

///|
fn ascii_lower(word : String) -> String? {
  let b = StringBuilder()
  for c in word.iter() {
    let cp = c.to_int()
    if cp >= 65 && cp <= 90 {
      b.write_char((cp + 32).unsafe_to_char())
    } else if cp >= 97 && cp <= 122 {
      b.write_char(c)
    } else {
      return None
    }
  }
  Some(b.to_string())
}

///|
/// Compile patterns such as `a1bc3` (odd weights permit breaks, even suppress).
/// Malformed patterns/exceptions are ignored atomically. Exceptions use literal
/// hyphens, e.g. `hy-phen-ation`; unhyphenated exceptions suppress all breaks.
pub fn Liang::new(
  patterns : Array[String],
  exceptions? : Array[String] = [],
  left_min? : Int = 2,
  right_min? : Int = 3,
) -> Liang {
  let nodes : Array[Node] = [{ children: {}, weights: [], }]
  for pattern in patterns {
    let letters = []
    let weights = [0]
    let mut valid = true
    for c in pattern.iter() {
      let cp = c.to_int()
      if cp >= 48 && cp <= 57 {
        weights[weights.length() - 1] = cp - 48
      } else if cp == 46 || (cp >= 97 && cp <= 122) {
        letters.push(cp)
        weights.push(0)
      } else {
        valid = false
      }
    }
    if !valid || letters.is_empty() {
      continue
    }
    let mut node = 0
    for letter in letters {
      match nodes[node].children.get(letter) {
        Some(child) => node = child
        None => {
          let child = nodes.length()
          nodes.push({ children: {}, weights: [], })
          nodes[node].children.set(letter, child)
          node = child
        }
      }
    }
    if nodes[node].weights.is_empty() {
      for w in weights {
        nodes[node].weights.push(w)
      }
    } else {
      for i, w in weights {
        if w > nodes[node].weights[i] {
          nodes[node].weights[i] = w
        }
      }
    }
  }
  let lookup : Map[String, Array[Int]] = Map([])
  for exception in exceptions {
    let b = StringBuilder()
    let points = []
    let mut offset = 0
    for c in exception.iter() {
      if c == '-' {
        points.push(offset)
      } else {
        b.write_char(c)
        offset += 1
      }
    }
    if ascii_lower(b.to_string()) is Some(key) {
      lookup.set(key, points)
    }
  }
  {
    nodes,
    exceptions: lookup,
    left_min: if left_min > 0 {
      left_min
    } else {
      1
    },
    right_min: if right_min > 0 {
      right_min
    } else {
      1
    },
  }
}

///|
/// Find allowed byte offsets. Non-ASCII words and punctuation return no breaks.
pub fn Liang::positions(self : Liang, word : String) -> Array[Int] {
  let key = match ascii_lower(word) {
    None => return []
    Some(k) => k
  }
  let n = key.length()
  if self.left_min >= n || self.right_min >= n {
    return []
  }
  let margin = fn(i) { i >= self.left_min && i <= n - self.right_min }
  if self.exceptions.get(key) is Some(points) {
    return points.filter(margin)
  }
  let chars = ("." + key + ".").iter().map(fn(c) { c.to_int() }).to_array()
  let weights = Array::make(chars.length() + 1, 0)
  for start = 0; start < chars.length(); start = start + 1 {
    let mut node = 0
    for i = start; i < chars.length(); i = i + 1 {
      match self.nodes[node].children.get(chars[i]) {
        None => break
        Some(child) => node = child
      }
      for j, w in self.nodes[node].weights {
        if w > weights[start + j] {
          weights[start + j] = w
        }
      }
    }
  }
  let result = []
  for i = self.left_min; i <= n - self.right_min; i = i + 1 {
    if weights[i + 1] % 2 == 1 {
      result.push(i)
    }
  }
  result
}

///|
pub impl Hyphenator for Liang with fn positions(self, word) {
  self.positions(word)
}

///|
/// American English patterns from hyph-utf8, default margins 2/3. Construct once
/// and reuse the trie. Source and licensing: testdata/hyphen/hyph-en-us.tex.
pub fn Liang::english() -> Liang {
  Liang::new(
    english_patterns.split(" ").map(fn(s) { s.to_owned() }).to_array(),
    exceptions=english_exceptions
      .split(" ")
      .map(fn(s) { s.to_owned() })
      .to_array(),
  )
}
