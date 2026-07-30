///|
test "LogHistogram empty" {
  let h = LogHistogram::new()
  if !(h.total_count() == 0L) { abort("empty total should be 0") }
}

///|
test "LogHistogram record" {
  let h = LogHistogram::new().record(100L).record(1000L).record(10000L)
  if !(h.total_count() == 3L) { abort("total should be 3") }
}

///|
test "LogHistogram percentile" {
  let h = LogHistogram::new()
  let mut h1 = h
  let mut i = 0
  while i < 100 {
    h1 = h1.record(1000L)
    i = i + 1
  }
  match h1.percentile(50) {
    None => abort("P50 should exist")
    Some(p) => if !(p > 0L) { abort("P50 should be > 0") }
  }
}

///|
test "LogHistogram percentile extremes" {
  let h = LogHistogram::new().record(1L).record(1000000L)
  match h.percentile(0) {
    None => abort("P0 should exist")
    Some(p) => if !(p == 0L) { abort("P0 should be 0") }
  }
  match h.percentile(100) {
    None => abort("P100 should exist")
    Some(p) => if !(p == 1000000L) { abort("P100 should be 1000000") }
  }
}
