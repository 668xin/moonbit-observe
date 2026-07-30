///|
test "RegressionDetector no baseline returns None" {
  let store = BaselineStore::new()
  let detector = RegressionDetector::new(store, 110L)
  let current = StatisticalSummary::new().add(200L)
  match detector.detect("missing", current) {
    None => () // expected
    Some(_) => abort("should be None for missing baseline")
  }
}

///|
test "RegressionDetector detects regression" {
  let summary = StatisticalSummary::new().add(100L)
  let store = BaselineStore::new().add("func_test", summary)
  let detector = RegressionDetector::new(store, 110L)
  let current = StatisticalSummary::new().add(200L)
  match detector.detect("func_test", current) {
    None => abort("result should exist")
    Some(r) => {
      if !r.is_regression() { abort("should be regression") }
      if !(r.baseline_mean() == 100L) { abort("baseline should be 100") }
      if !(r.current_mean() == 200L) { abort("current should be 200") }
      if !(r.ratio() == 200L) { abort("ratio should be 200") }
    }
  }
}

///|
test "RegressionDetector no regression within threshold" {
  let summary = StatisticalSummary::new().add(200L)
  let store = BaselineStore::new().add("func_test", summary)
  let detector = RegressionDetector::new(store, 200L)
  let current = StatisticalSummary::new().add(199L)
  match detector.detect("func_test", current) {
    None => abort("result should exist")
    Some(r) => {
      if r.is_regression() { abort("should NOT be regression") }
    }
  }
}

///|
test "RegressionDetector exact match is not regression" {
  let summary = StatisticalSummary::new().add(100L)
  let store = BaselineStore::new().add("func_test", summary)
  let detector = RegressionDetector::new(store, 110L)
  let current = StatisticalSummary::new().add(100L)
  match detector.detect("func_test", current) {
    None => abort("result should exist")
    Some(r) => {
      if r.is_regression() { abort("exact match should NOT be regression") }
      if !(r.ratio() == 100L) { abort("ratio should be 100") }
    }
  }
}

///|
test "RegressionDetector current slower than baseline" {
  let summary = StatisticalSummary::new().add(100L)
  let store = BaselineStore::new().add("func", summary)
  let detector = RegressionDetector::new(store, 110L)
  let current = StatisticalSummary::new().add(115L)
  match detector.detect("func", current) {
    None => abort("result should exist")
    Some(r) => {
      if !r.is_regression() { abort("115% should be regression") }
      if !(r.ratio() == 115L) { abort("ratio should be 115") }
    }
  }
}
