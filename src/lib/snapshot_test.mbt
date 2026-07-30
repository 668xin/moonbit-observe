///|
test "Snapshot::new creates empty snapshot" {
  let snap = @lib.Snapshot::new(1000L)
  if !(snap.timestamp() == 1000L) { abort("timestamp should be 1000") }
  if !(snap.entry_count() == 0) { abort("new snapshot should have 0 entries") }
}

///|
test "Snapshot::add_timing adds entry" {
  let snap = @lib.Snapshot::new(1000L).add_timing("test", 500L, [])
  if !(snap.entry_count() == 1) { abort("should have 1 entry") }
}

///|
test "Snapshot::add_benchmark adds entry" {
  let result = @lib.BenchmarkResult::new(10L, 20L, 15L, 100L)
  let snap = @lib.Snapshot::new(2000L).add_benchmark(result)
  if !(snap.entry_count() == 1) { abort("should have 1 benchmark entry") }
}

///|
test "Snapshot::add_span adds entry" {
  let span = @lib.Span::new("root").start().stop()
  let snap = @lib.Snapshot::new(3000L).add_span(span)
  if !(snap.entry_count() == 1) { abort("should have 1 span entry") }
}

///|
test "Snapshot::multiple entries" {
  let result = @lib.BenchmarkResult::new(1L, 2L, 1L, 3L)
  let span = @lib.Span::new("s").start().stop()
  let snap = @lib.Snapshot::new(100L)
    .add_timing("t1", 100L, [])
    .add_benchmark(result)
    .add_span(span)
  if !(snap.entry_count() == 3) { abort("should have 3 entries") }
}

///|
test "Snapshot::entries returns all entries" {
  let snap = @lib.Snapshot::new(1L)
    .add_timing("t", 10L, [])
  let entries = snap.entries()
  if !(entries.length() == 1) { abort("entries length should be 1") }
}

///|
test "Snapshot::to_json produces valid JSON" {
  let snap = @lib.Snapshot::new(12345L)
    .add_timing("request", 1500L, [])
  let json = snap.to_json()
  if !(json.length() > 0) { abort("json should not be empty") }
  if !(json.contains("12345")) { abort("json should contain timestamp") }
  if !(json.contains("request")) { abort("json should contain name") }
  if !(json.contains("timing")) { abort("json should contain type") }
  if !(json.contains("1500")) { abort("json should contain elapsed_nanos") }
}

///|
test "Snapshot::to_json with benchmark entry" {
  let result = @lib.BenchmarkResult::new(10L, 100L, 50L, 500L)
  let snap = @lib.Snapshot::new(1L).add_benchmark(result)
  let json = snap.to_json()
  if !(json.contains("benchmark")) { abort("json should contain benchmark type") }
  if !(json.contains("50")) { abort("json should contain avg_nanos") }
}

///|
test "Snapshot::to_json with span entry" {
  let span = @lib.Span::new("api-call").start().stop()
  let snap = @lib.Snapshot::new(1L).add_span(span)
  let json = snap.to_json()
  if !(json.contains("span")) { abort("json should contain span type") }
  if !(json.contains("api-call")) { abort("json should contain span name") }
}

///|
test "Snapshot JSON round-trip: timing entry" {
  let snap = @lib.Snapshot::new(9999L)
    .add_timing("roundtrip", 777L, [])
  let json = snap.to_json()
  let restored = @lib.Snapshot::from_json(json)
  if !(restored.timestamp() == 9999L) { abort("timestamp should roundtrip, got " + restored.timestamp().to_string()) }
  if !(restored.entry_count() >= 1) { abort("roundtrip should have entries") }
}

///|
test "Snapshot JSON round-trip: benchmark entry" {
  let result = @lib.BenchmarkResult::new(5L, 50L, 25L, 250L)
  let snap = @lib.Snapshot::new(8888L).add_benchmark(result)
  let json = snap.to_json()
  let restored = @lib.Snapshot::from_json(json)
  if !(restored.timestamp() == 8888L) { abort("benchmark timestamp should roundtrip") }
  if !(restored.entry_count() >= 1) { abort("benchmark roundtrip should have entries") }
}

///|
test "Snapshot::to_json empty snapshot" {
  let snap = @lib.Snapshot::new(0L)
  let json = snap.to_json()
  if !(json.contains("entries")) { abort("empty snapshot should have entries field") }
}

///|
test "Snapshot::from_json empty entries" {
  let json = "{\n  \"timestamp\": 0,\n  \"entries\": [\n  ]\n}"
  let snap = @lib.Snapshot::from_json(json)
  if !(snap.timestamp() == 0L) { abort("parsed timestamp should be 0") }
  if !(snap.entry_count() == 0) { abort("parsed entries should be empty") }
}
