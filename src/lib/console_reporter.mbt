///|
/// ConsoleReporter — 控制台格式化输出
///
/// 将计时结果格式化输出到控制台。支持配置时间单位和是否显示分段。
pub struct ConsoleReporter {
  priv time_unit : TimeUnit
  priv show_laps : Bool
  priv show_header : Bool
}

///|
/// 创建默认 ConsoleReporter（Auto 单位，显示分段，显示标题）
pub fn ConsoleReporter::new() -> ConsoleReporter {
  { time_unit: Auto, show_laps: true, show_header: true }
}

///|
/// 创建带选项的 ConsoleReporter
pub fn ConsoleReporter::with_options(time_unit : TimeUnit, show_laps : Bool, show_header : Bool) -> ConsoleReporter {
  { time_unit, show_laps, show_header }
}

///|
/// 输出 Stopwatch 计时结果
pub fn ConsoleReporter::report_stopwatch(self : ConsoleReporter, name : String, elapsed_nanos : Int64, laps : Array[LapRecord]) -> Unit {
  if self.show_header {
    println("=== Stopwatch Report ===")
  }
  println("  Name: " + name)
  println("  Elapsed: " + format_nanos_with_unit(elapsed_nanos, self.time_unit))
  if self.show_laps && laps.length() > 0 {
    println("  Laps:")
    let mut i = 0
    while i < laps.length() {
      let lap = laps[i]
      println(
        "    [" + (i + 1).to_string() + "] " +
        lap.label() + ": split=" +
        format_nanos_with_unit(lap.lap_nanos(), self.time_unit) +
        ", total=" +
        format_nanos_with_unit(lap.total_nanos(), self.time_unit),
      )
      i = i + 1
    }
  }
  println("")
}

///|
/// 输出基准测试结果
pub fn ConsoleReporter::report_benchmark(self : ConsoleReporter, result : BenchmarkResult) -> Unit {
  if self.show_header {
    println("=== Benchmark Report ===")
  }
  println("  Min:   " + format_nanos_with_unit(result.min_nanos(), self.time_unit))
  println("  Max:   " + format_nanos_with_unit(result.max_nanos(), self.time_unit))
  println("  Avg:   " + format_nanos_with_unit(result.avg_nanos(), self.time_unit))
  println("  Total: " + format_nanos_with_unit(result.total_nanos(), self.time_unit))
  println("")
}

///|
/// 输出 Span 树
pub fn ConsoleReporter::report_span(self : ConsoleReporter, span : Span) -> Unit {
  if self.show_header {
    println("=== Span Report ===")
  }
  print_span_tree(span, 0, self.time_unit)
  println("")
}

fn print_span_tree(s : Span, depth : Int, unit : TimeUnit) -> Unit {
  let indent = String::make(depth * 2, ' ')
  let elapsed_fmt = format_nanos_with_unit(s.elapsed_nanos(), unit)
  let status = if s.is_running() { " (running)" } else { "" }
  println(indent + "- " + s.name() + ": " + elapsed_fmt + status)
  let children = s.children()
  let mut i = 0
  while i < children.length() {
    print_span_tree(children[i], depth + 1, unit)
    i = i + 1
  }
}

///|
/// 输出快照
pub fn ConsoleReporter::report_snapshot(self : ConsoleReporter, snapshot : Snapshot) -> Unit {
  if self.show_header {
    println("=== Snapshot Report ===")
  }
  let ts = snapshot.timestamp()
  println("  Timestamp: " + ts.to_string())
  println("  Entries: " + snapshot.entry_count().to_string())
  let entries = snapshot.entries()
  let mut i = 0
  while i < entries.length() {
    let entry_str = match entries[i] {
      TimingEntry(name, elapsed, laps) => {
        let lap_count_str = laps.length().to_string()
        "Timing: " + name + " (" + format_nanos_with_unit(elapsed, self.time_unit) + ", " + lap_count_str + " laps)"
      }
      BenchmarkEntry(r) => {
        "Benchmark: min=" + format_nanos_with_unit(r.min_nanos(), self.time_unit) +
          ", avg=" + format_nanos_with_unit(r.avg_nanos(), self.time_unit) +
          ", max=" + format_nanos_with_unit(r.max_nanos(), self.time_unit)
      }
      SpanEntry(s) => {
        "Span: " + s.name() + " (" + format_nanos_with_unit(s.elapsed_nanos(), self.time_unit) + ")"
      }
    }
    println("    [" + (i + 1).to_string() + "] " + entry_str)
    i = i + 1
  }
  println("")
}

///|
/// 刷新（ConsoleReporter 无缓冲，无操作）
pub fn ConsoleReporter::flush(_self : ConsoleReporter) -> Unit {
  // no-op for console
}
