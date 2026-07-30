///|
/// CompositeReporter — 多 Reporter 组合
///
/// 将多个 Reporter 组合在一起，调用时依次转发给所有子 Reporter。
/// 支持通过闭包方式添加任意报告处理器。
pub struct CompositeReporter {
  priv stopwatch_fns : Ref[Array[(String, Int64, Array[LapRecord]) -> Unit]]
  priv benchmark_fns : Ref[Array[(BenchmarkResult) -> Unit]]
  priv span_fns : Ref[Array[(Span) -> Unit]]
  priv snapshot_fns : Ref[Array[(Snapshot) -> Unit]]
  priv flush_fns : Ref[Array[() -> Unit]]
}

///|
/// 创建空的组合报告器
pub fn CompositeReporter::new() -> CompositeReporter {
  {
    stopwatch_fns: { val: [] },
    benchmark_fns: { val: [] },
    span_fns: { val: [] },
    snapshot_fns: { val: [] },
    flush_fns: { val: [] },
  }
}

///|
/// 添加一个 Stopwatch 报告处理器
pub fn CompositeReporter::add_stopwatch_fn(self : CompositeReporter, f : (String, Int64, Array[LapRecord]) -> Unit) -> Unit {
  self.stopwatch_fns.val = self.stopwatch_fns.val + [f]
}

///|
/// 添加一个基准测试报告处理器
pub fn CompositeReporter::add_benchmark_fn(self : CompositeReporter, f : (BenchmarkResult) -> Unit) -> Unit {
  self.benchmark_fns.val = self.benchmark_fns.val + [f]
}

///|
/// 添加一个 Span 报告处理器
pub fn CompositeReporter::add_span_fn(self : CompositeReporter, f : (Span) -> Unit) -> Unit {
  self.span_fns.val = self.span_fns.val + [f]
}

///|
/// 添加一个快照报告处理器
pub fn CompositeReporter::add_snapshot_fn(self : CompositeReporter, f : (Snapshot) -> Unit) -> Unit {
  self.snapshot_fns.val = self.snapshot_fns.val + [f]
}

///|
/// 添加一个刷新处理器
pub fn CompositeReporter::add_flush_fn(self : CompositeReporter, f : () -> Unit) -> Unit {
  self.flush_fns.val = self.flush_fns.val + [f]
}

///|
/// 添加一个 ConsoleReporter 全部方法
pub fn CompositeReporter::add_console(self : CompositeReporter, console : ConsoleReporter) -> Unit {
  let c = console
  self.add_stopwatch_fn(fn(name, nanos, laps) { c.report_stopwatch(name, nanos, laps) })
  self.add_benchmark_fn(fn(r) { c.report_benchmark(r) })
  self.add_span_fn(fn(s) { c.report_span(s) })
  self.add_snapshot_fn(fn(snap) { c.report_snapshot(snap) })
  self.add_flush_fn(fn() { c.flush() })
}

///|
/// 添加一个 JsonReporter 全部方法
pub fn CompositeReporter::add_json(self : CompositeReporter, json : JsonReporter) -> Unit {
  let j = json
  self.add_stopwatch_fn(fn(name, nanos, laps) { j.report_stopwatch(name, nanos, laps) })
  self.add_benchmark_fn(fn(r) { j.report_benchmark(r) })
  self.add_span_fn(fn(s) { j.report_span(s) })
  self.add_snapshot_fn(fn(snap) { j.report_snapshot(snap) })
  self.add_flush_fn(fn() { j.flush() })
}

///|
/// 获取 Stopwatch 处理器数量
pub fn CompositeReporter::stopwatch_count(self : CompositeReporter) -> Int {
  self.stopwatch_fns.val.length()
}

///|
/// 获取基准测试处理器数量
pub fn CompositeReporter::benchmark_count(self : CompositeReporter) -> Int {
  self.benchmark_fns.val.length()
}

///|
/// 转发 Stopwatch 报告给所有处理器
pub fn CompositeReporter::report_stopwatch(self : CompositeReporter, name : String, elapsed_nanos : Int64, laps : Array[LapRecord]) -> Unit {
  let fns = self.stopwatch_fns.val
  let mut i = 0
  while i < fns.length() {
    fns[i](name, elapsed_nanos, laps)
    i = i + 1
  }
}

///|
/// 转发基准测试报告给所有处理器
pub fn CompositeReporter::report_benchmark(self : CompositeReporter, result : BenchmarkResult) -> Unit {
  let fns = self.benchmark_fns.val
  let mut i = 0
  while i < fns.length() {
    fns[i](result)
    i = i + 1
  }
}

///|
/// 转发 Span 报告给所有处理器
pub fn CompositeReporter::report_span(self : CompositeReporter, span : Span) -> Unit {
  let fns = self.span_fns.val
  let mut i = 0
  while i < fns.length() {
    fns[i](span)
    i = i + 1
  }
}

///|
/// 转发快照报告给所有处理器
pub fn CompositeReporter::report_snapshot(self : CompositeReporter, snapshot : Snapshot) -> Unit {
  let fns = self.snapshot_fns.val
  let mut i = 0
  while i < fns.length() {
    fns[i](snapshot)
    i = i + 1
  }
}

///|
/// 转发刷新请求给所有处理器
pub fn CompositeReporter::flush(self : CompositeReporter) -> Unit {
  let fns = self.flush_fns.val
  let mut i = 0
  while i < fns.length() {
    fns[i]()
    i = i + 1
  }
}
