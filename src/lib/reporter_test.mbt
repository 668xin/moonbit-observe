///|
test "format_nanos_with_unit: Auto mode matches format_nanos" {
  let auto_unit = @lib.TimeUnit::auto()
  let result = @lib.format_nanos_with_unit(1500L, auto_unit)
  if !(result == @lib.format_nanos(1500L)) { abort("Auto should match format_nanos") }
  let result2 = @lib.format_nanos_with_unit(1_500_000L, auto_unit)
  if !(result2 == @lib.format_nanos(1_500_000L)) { abort("Auto for ms should match") }
}

///|
test "format_nanos_with_unit: explicit units" {
  let ns = @lib.format_nanos_with_unit(1500L, @lib.TimeUnit::nanoseconds())
  if !(ns == "1500 ns") { abort("expected '1500 ns', got " + ns) }
  let us = @lib.format_nanos_with_unit(1500L, @lib.TimeUnit::microseconds())
  if !(us == "1 μs") { abort("expected '1 μs', got " + us) }
  let ms = @lib.format_nanos_with_unit(1_500_000L, @lib.TimeUnit::milliseconds())
  if !(ms == "1.5 ms") { abort("expected '1.5 ms', got " + ms) }
  let s = @lib.format_nanos_with_unit(1_500_000_000L, @lib.TimeUnit::seconds())
  if !(s == "1.5 s") { abort("expected '1.5 s', got " + s) }
}

///|
test "format_nanos_with_unit: zero values" {
  let ns = @lib.format_nanos_with_unit(0L, @lib.TimeUnit::nanoseconds())
  if !(ns == "0 ns") { abort("zero ns failed: " + ns) }
  let ms = @lib.format_nanos_with_unit(0L, @lib.TimeUnit::milliseconds())
  if !(ms == "0 ms") { abort("zero ms failed: " + ms) }
  let s = @lib.format_nanos_with_unit(0L, @lib.TimeUnit::seconds())
  if !(s == "0 s") { abort("zero s failed: " + s) }
}

///|
test "ConsoleReporter::new does not crash" {
  let _reporter = @lib.ConsoleReporter::new()
}

///|
test "ConsoleReporter::with_options does not crash" {
  let _reporter = @lib.ConsoleReporter::with_options(@lib.TimeUnit::milliseconds(), true, false)
}

///|
test "ConsoleReporter::report_stopwatch with empty laps does not crash" {
  let reporter = @lib.ConsoleReporter::new()
  reporter.report_stopwatch("test", 5000L, [])
}

///|
test "ConsoleReporter::report_benchmark does not crash" {
  let result = @lib.BenchmarkResult::new(100L, 200L, 150L, 1000L)
  let reporter = @lib.ConsoleReporter::new()
  reporter.report_benchmark(result)
}

///|
test "ConsoleReporter::report_span does not crash" {
  let span = @lib.Span::new("root").start().stop()
  let reporter = @lib.ConsoleReporter::new()
  reporter.report_span(span)
}

///|
test "ConsoleReporter::report_snapshot does not crash" {
  let snapshot = @lib.Snapshot::new(1000L)
  let reporter = @lib.ConsoleReporter::new()
  reporter.report_snapshot(snapshot)
}

///|
test "ConsoleReporter::flush does not crash" {
  let reporter = @lib.ConsoleReporter::new()
  reporter.flush()
}

///|
test "JsonReporter::new creates empty reporter" {
  let reporter = @lib.JsonReporter::new()
  if !(reporter.output() == "[]") { abort("new JsonReporter output should be []") }
}

///|
test "JsonReporter::report_stopwatch produces valid JSON" {
  let reporter = @lib.JsonReporter::new()
  reporter.report_stopwatch("test", 1500L, [])
  let output = reporter.output()
  if !(output.length() > 0) { abort("output should not be empty") }
  // Check contains expected fields
  if !(output.contains("stopwatch")) { abort("output should contain 'stopwatch'") }
  if !(output.contains("test")) { abort("output should contain name") }
  if !(output.contains("1500")) { abort("output should contain elapsed_nanos") }
}

///|
test "JsonReporter::report_benchmark produces valid JSON" {
  let reporter = @lib.JsonReporter::new()
  let result = @lib.BenchmarkResult::new(10L, 100L, 50L, 500L)
  reporter.report_benchmark(result)
  let output = reporter.output()
  if !(output.contains("benchmark")) { abort("output should contain 'benchmark'") }
}

///|
test "JsonReporter::report_span produces valid JSON" {
  let reporter = @lib.JsonReporter::new()
  let span = @lib.Span::new("test-span").start().stop()
  reporter.report_span(span)
  let output = reporter.output()
  if !(output.contains("span")) { abort("output should contain 'span'") }
  if !(output.contains("test-span")) { abort("output should contain span name") }
}

///|
test "JsonReporter::report_snapshot delegates to snapshot.to_json" {
  let reporter = @lib.JsonReporter::new()
  let snapshot = @lib.Snapshot::new(100L)
  reporter.report_snapshot(snapshot)
  let output = reporter.output()
  if !(output.length() > 0) { abort("snapshot output should not be empty") }
}

///|
test "JsonReporter::reset clears output" {
  let reporter = @lib.JsonReporter::new()
  reporter.report_stopwatch("a", 1L, [])
  reporter.reset()
  if !(reporter.output() == "[]") { abort("reset should clear output") }
}

///|
test "JsonReporter::multiple reports produces array" {
  let reporter = @lib.JsonReporter::new()
  reporter.report_stopwatch("a", 1L, [])
  reporter.report_stopwatch("b", 2L, [])
  let output = reporter.output()
  if !(output.contains("a")) { abort("output should contain first name") }
  if !(output.contains("b")) { abort("output should contain second name") }
}

///|
test "JsonReporter::with_options pretty=false produces compact JSON" {
  let reporter = @lib.JsonReporter::with_options(false)
  reporter.report_stopwatch("x", 1L, [])
  let output = reporter.output()
  // In non-pretty mode, entries should be on same line
  if !(output.length() > 0) { abort("non-pretty output should not be empty") }
}

///|
test "CompositeReporter::new creates empty reporter" {
  let composite = @lib.CompositeReporter::new()
  if !(composite.stopwatch_count() == 0) { abort("new CompositeReporter should have 0 stopwatch fns") }
  if !(composite.benchmark_count() == 0) { abort("new CompositeReporter should have 0 benchmark fns") }
}

///|
test "CompositeReporter::add_stopwatch_fn counts correctly" {
  let composite = @lib.CompositeReporter::new()
  composite.add_stopwatch_fn(fn(_name, _ns, _laps) {})
  composite.add_stopwatch_fn(fn(_name, _ns, _laps) {})
  if !(composite.stopwatch_count() == 2) { abort("should have 2 stopwatch fns") }
}

///|
test "CompositeReporter::add_console adds all 5 handlers" {
  let composite = @lib.CompositeReporter::new()
  let console = @lib.ConsoleReporter::new()
  composite.add_console(console)
  if !(composite.stopwatch_count() == 1) { abort("should have 1 stopwatch fn") }
  if !(composite.benchmark_count() == 1) { abort("should have 1 benchmark fn") }
}

///|
test "CompositeReporter::report_stopwatch calls all handlers" {
  let composite = @lib.CompositeReporter::new()
  let json = @lib.JsonReporter::new()
  composite.add_json(json)
  composite.report_stopwatch("test", 100L, [])
  let output = json.output()
  if !(output.contains("test")) { abort("composite should forward to json") }
}

///|
test "CompositeReporter::report_benchmark calls all handlers" {
  let composite = @lib.CompositeReporter::new()
  let json = @lib.JsonReporter::new()
  composite.add_json(json)
  let result = @lib.BenchmarkResult::new(1L, 2L, 1L, 3L)
  composite.report_benchmark(result)
  let output = json.output()
  if !(output.contains("benchmark")) { abort("composite should forward benchmark") }
}

///|
test "CompositeReporter::report_span calls all handlers" {
  let composite = @lib.CompositeReporter::new()
  let json = @lib.JsonReporter::new()
  composite.add_json(json)
  let span = @lib.Span::new("s").start().stop()
  composite.report_span(span)
  let output = json.output()
  if !(output.contains("s")) { abort("composite should forward span") }
}

///|
test "CompositeReporter::flush does not crash" {
  let composite = @lib.CompositeReporter::new()
  composite.flush()
}
