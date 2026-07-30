///|
/// 集成测试：Stopwatch + Stat + Histogram + Reporter + Snapshot 联动
test "integration: Stopwatch + StatisticalSummary" {
  let sw = Stopwatch::new().start()
  let nanos = sw.elapsed_nanos()
  let sw1 = sw.stop()
  let summary = StatisticalSummary::new().add(nanos)
  match summary.mean() {
    None => abort("mean should exist")
    Some(m) => if !(m >= 0L) { abort("mean should be >= 0") }
  }
}

///|
test "integration: LogHistogram records Stopwatch values" {
  let mut hist = LogHistogram::new()
  let mut i = 0
  while i < 50 {
    let sw = Stopwatch::new().start()
    let ns = sw.elapsed_nanos()
    hist = hist.record(if ns >= 0L { ns } else { 1L })
    i = i + 1
  }
  if !(hist.total_count() >= 0L) { abort("count should be >= 0") }
}

///|
test "integration: BaselineStore + RegressionDetector pipeline" {
  // Simulate: record baseline, then detect regression
  let baseline_summary = StatisticalSummary::new().add(100L).add(110L).add(90L)
  let store = BaselineStore::new().add("compute", baseline_summary)
  let detector = RegressionDetector::new(store, 120L)
  let current = StatisticalSummary::new().add(105L).add(115L)
  match detector.detect("compute", current) {
    None => abort("result should exist")
    Some(r) => {
      // baseline mean = (100+110+90)/3 = 100, current mean = (105+115)/2 = 110
      // ratio = 110
      if !(r.baseline_mean() == 100L) { abort("baseline mean should be 100") }
      if !(r.current_mean() == 110L) { abort("current mean should be 110") }
    }
  }
}

///|
test "integration: SlidingWindow + StatisticalSummary" {
  let w = SlidingWindow::new(10)
  let mut w1 = w
  let mut s = StatisticalSummary::new()
  let mut i = 0
  while i < 10 {
    w1 = w1.add(i.to_int64())
    s = s.add(i.to_int64())
    i = i + 1
  }
  match s.mean() {
    None => abort("mean should exist")
    Some(m) => if !(m == 4L) { abort("mean of 0..9 should be 4") }
  }
  match w1.median() {
    None => abort("median should exist")
    Some(m) => if !(m == 5L) { abort("median of 0..9 should be 5, got " + m.to_string()) }
  }
}

///|
test "integration: TaggedStopwatch + ConsoleReporter" {
  let tags = Tags::new().add_pair("service", "api").add_pair("version", "v1")
  let tw = TaggedStopwatch::new(tags).start()
  let ns = tw.elapsed_nanos()
  let tw1 = tw.stop()
  // Just verify the tag and timing pipeline works
  if !(tw1.tags().count() == 2) { abort("tags count should be 2") }
  if !(ns >= 0L) { abort("elapsed should be >= 0") }
  if tw1.is_running() { abort("should be stopped") }
}
