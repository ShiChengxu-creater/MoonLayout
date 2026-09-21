///|
fn[T] lookup(ranges : ReadOnlyArray[(Int, Int, T)], cp : Int, default : T) -> T {
  let mut lo = 0
  let mut hi = ranges.length()
  while lo < hi {
    let mid = lo + (hi - lo) / 2
    let (first, last, property) = ranges[mid]
    if cp < first {
      hi = mid
    } else if cp > last {
      lo = mid + 1
    } else {
      return property
    }
  }
  default
}
