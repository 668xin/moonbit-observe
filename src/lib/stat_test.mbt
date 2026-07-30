///|
test "StatisticalSummary empty" {
  let s = StatisticalSummary::new()
  if !(s.count() == 0L) { abort("count should be 0") }
  match s.mean() {
    None => () // expected
    _ => abort("mean of empty should be None")
  }
}

///|
test "StatisticalSummary single value" {
  let s = StatisticalSummary::new().add(100L)
  if !(s.count() == 1L) { abort("count should be 1") }
  match s.mean() {
    None => abort("mean should exist")
    Some(m) => if !(m == 100L) { abort("mean should be 100") }
  }
  match s.min() {
    None => abort("min should exist")
    Some(m) => if !(m == 100L) { abort("min should be 100") }
  }
  match s.max() {
    None => abort("max should exist")
    Some(m) => if !(m == 100L) { abort("max should be 100") }
  }
}

///|
test "StatisticalSummary multiple values" {
  let s = StatisticalSummary::new().add(10L).add(20L).add(30L)
  match s.mean() {
    None => abort("mean should exist")
    Some(m) => if !(m == 20L) { abort("mean should be 20") }
  }
  match s.min() {
    None => abort("min should exist")
    Some(m) => if !(m == 10L) { abort("min should be 10") }
  }
  match s.max() {
    None => abort("max should exist")
    Some(m) => if !(m == 30L) { abort("max should be 30") }
  }
  match s.range() {
    None => abort("range should exist")
    Some(r) => if !(r == 20L) { abort("range should be 20") }
  }
}

///|
test "StatisticalSummary stddev" {
  let s = StatisticalSummary::new().add(10L).add(10L).add(10L)
  match s.stddev() {
    None => abort("stddev should exist")
    Some(sd) => if !(sd == 0L) { abort("stddev should be 0, got " + sd.to_string()) }
  }
}
