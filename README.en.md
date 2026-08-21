# moonbit-observe

A lightweight, high-performance runtime timing and metrics observation SDK built with [MoonBit](https://www.moonbitlang.com/). Supports **precise timing**, **lap timing**, **pause/resume**, **benchmarking**, **statistics**, **regression detection**, and **JSON export**.

## Project Intro

moonbit-observe is an original, general-purpose runtime timing and metrics observation toolkit for the MoonBit ecosystem.

The ecosystem currently lacks an out-of-the-box, standardized observation component supporting lap timing. Developers measuring elapsed time in business programs, scripts, or services can only hand-write ad-hoc timing code, missing capabilities like multi-phase lap timing, async task timing, and human-friendly formatting.

The core positioning of this project is a **runtime instrumentation timing and observation tool** for multi-phase timing statistics and flow duration observation during application development. A simple benchmark capability is provided as an optional accessory, not the project core.

> Differentiation from the existing moonbench:
> moonbench targets `moon bench`, focusing on in-source unit-style benchmarking and CI performance comparison;
> moonbit-observe targets runtime dynamic timing, with core capabilities being Stopwatch, lap timing, and async task timing — suitable for business code instrumentation and multi-flow phase duration observation. The use cases and core goals are completely different.

The library is built purely on the MoonBit standard library with **zero external dependencies**, and can be directly imported into any MoonBit project.

## Features

- **High-precision timing** — nanosecond resolution, with convenience methods for micro/milli/seconds
- **Pause/Resume** — pause anytime and resume to accumulate elapsed time
- **Lap timing** — record labeled lap splits with automatic accumulation
- **Benchmarking** — built-in warmup + multiple runs + statistical analysis
- **Formatting** — auto unit switching (ns / μs / ms / s)
- **JSON export** — serialize benchmark results to JSON
- **Async timer** — `AsyncTimer` wrapper for async task timing
- **Reporter system** — Console/JSON/Multi-reporter output for all timing data
- **Snapshot** — point-in-time capture with JSON serialization/deserialization
- **CompositeReporter** — combine multiple reporters (console + JSON) in one pass
- **Immutable design** — every operation returns a new instance, side-effect free

## Installation

Add the dependency to your `moon.mod`:

```toml
[deps]
"668xin/moonbit-observe" = "0.1.0"
```

Or via the CLI:

```bash
moon add 668xin/moonbit-observe
```

## Quick Start

```moonbit
fn main {
  // Create a new stopwatch (idle)
  let sw = @lib.Stopwatch::new()

  // Start timing
  let sw1 = sw.start()

  // Read elapsed time
  println("nanos: {sw1.elapsed_nanos()}")
  println("millis: {sw1.elapsed_millis()}")
  println("formatted: {sw1.elapsed_fmt()}")

  // Pause
  let sw2 = sw1.stop()

  // Resume
  let sw3 = sw2.resume()

  // Reset
  let sw4 = sw3.reset()
}
```

## API Overview

### Core `Stopwatch`

```
┌─ Stopwatch ──────────────────────────────┐
│  Stopwatch::new()       Create a timer    │
│  .start()               Start timing      │
│  .stop()                Pause             │
│  .resume()              Resume            │
│  .reset()               Reset             │
│  .elapsed_nanos()       Get nanoseconds   │
│  .elapsed_micros()      Get microseconds  │
│  .elapsed_millis()      Get milliseconds  │
│  .elapsed_secs()        Get seconds (f64) │
│  .elapsed_fmt()         Human-readable    │
│  .is_running()          Check if running  │
│  .lap(label)            Record a lap      │
│  .list_laps()           List all laps     │
│  .clear_laps()          Clear all laps    │
│  .lap_count()           Lap count         │
└──────────────────────────────────────────┘
```

### Lap Record `LapRecord`

```moonbit
pub struct LapRecord {
  label       : String   // Lap label
  lap_nanos   : Int64    // Split time (ns)
  total_nanos : Int64    // Cumulative time (ns)
}
```

### Benchmarking

```moonbit
// Config: warmup 5 times, run 10 times
let config = @lib.BenchmarkConfig::new(5, 10)
let runner = @lib.BenchmarkRunner::new(config)
let result = runner.run(fn() { /* code to benchmark */ })

// Print results
@lib.print_table(result)

// JSON export
let json = @lib.result_to_json(result)
```

### Formatting

```moonbit
// Nanosecond formatting with auto unit switching
@lib.format_nanos(1500L)          // → "1 μs"
@lib.format_nanos(1_500_000L)     // → "1.5 ms"
@lib.format_nanos(1_500_000_000L) // → "1.5 s"

// Time formatting: HH:MM:SS.mmm
@lib.format_time(3661.123)        // → "01:01:01.123"
```

### Clock Abstraction

moonbit-observe provides an injectable clock abstraction layer, decoupling business code from hardcoded system clock calls.

```moonbit
// Default system clock
let sw = @lib.Stopwatch::new()

// Custom clock function (monotonic, mock, etc.)
let sw = @lib.Stopwatch::new_with_clock(fn() { 1_700_000_000_000L })

// ClockProvider — unified clock injection
let provider = @lib.ClockProvider::system()
let sw = @lib.Stopwatch::new_with_provider(provider)

// ClockBackwardDetector — detect system clock rollback
let detector = @lib.ClockBackwardDetector::new()
let (detector, went_back) = detector.check(1_700_000_000_000L)
detector.backward_count() // → number of rollbacks
```

Use `MockClock` in tests to precisely control time advancement:

```moonbit
let clock = @lib.MockClock::new(0L).advance_millis(100L)
clock.now() // → 100_000_000
```

### Tags & Concurrency

```moonbit
// Tag — key-value tag system
let tags = @lib.Tags::new()
  .add_pair("service", "api")
  .add_pair("version", "v1")
tags.get("service") // → Some("api")

// TaggedStopwatch — stopwatch with bound tags
let tw = @lib.TaggedStopwatch::new(tags).start()
let tw = tw.stop()
tw.tags().count() // → 2

// SharedStopwatch — shared stopwatch (coroutine-safe, unique ID)
let shared = @lib.SharedStopwatch::new().start()
let shared = shared.stop()
shared.id() // → unique instance ID
```

### Async Timer `AsyncTimer`

```moonbit
let timer = @lib.AsyncTimer::new()
let timer = timer.start()
// ... async task ...
let (timer, elapsed_ns) = timer.stop()
```

### Statistics Engine

```moonbit
// StatisticalSummary — cumulative statistics
let summary = @lib.StatisticalSummary::new()
  .add(100L).add(200L).add(300L)

// Mean / Variance / StdDev
summary.mean()    // → Some(200)
summary.variance() // → Some(10000)
summary.stddev()   // → Some(100)

// Sliding window — fixed-capacity ring buffer
let window = @lib.SlidingWindow::new(5)
  .add(50L).add(10L).add(30L).add(20L).add(40L)
window.median() // → Some(30)

// Log histogram — P50/P90/P99 percentiles
let hist = @lib.LogHistogram::new()
  .record(100L).record(200L).record(300L)
hist.percentile(50) // → P50
```

### Baseline Persistence & Regression Detection

```moonbit
// Record baseline
let summary = @lib.StatisticalSummary::new().add(100L).add(200L)
let store = @lib.BaselineStore::new().add("compute_task", summary)

// Detect regression (threshold 110%)
let detector = @lib.RegressionDetector::new(store, 110)
let current = @lib.StatisticalSummary::new().add(180L)
match detector.detect("compute_task", current) {
  Some(r) => if r.is_regression() { println("Performance regression!") }
  None => println("No baseline data")
}
```

### Span Nested Timing

```moonbit
let parent = @lib.Span::new("request_handler").start()
let child = @lib.Span::new("db_query").start()
let child = child.stop()
let parent = parent.add_child(child).stop()
parent.total_elapsed_nanos() // includes child subtrees
```

### PhaseTimer Sequential Phase Timing

```moonbit
let pt = @lib.PhaseTimer::new()
  .begin_phase("receive")
  .begin_phase("process")  // auto-ends receive
  .begin_phase("respond")  // auto-ends process
  .end_phase()
pt.phases().length() // → 3
pt.total_elapsed_nanos()
```

### Reporter System

#### ConsoleReporter

```moonbit
let reporter = @lib.ConsoleReporter::new()
reporter.report_stopwatch("request", 1500000L, [])
// Output: === Stopwatch Report ===
//         Name: request
//         Elapsed: 1.5 ms

// Configure time unit / show laps / show header
let reporter = @lib.ConsoleReporter::with_options(
  @lib.TimeUnit::milliseconds(), false, true,
)
```

#### JsonReporter

```moonbit
let reporter = @lib.JsonReporter::new()
reporter.report_stopwatch("api", 1500L, [])
reporter.report_benchmark(result)
println(reporter.output())
// → [{"type":"stopwatch","name":"api",...},...]
reporter.reset()  // clear accumulated entries
```

#### Snapshot — point-in-time capture

```moonbit
let snap = @lib.Snapshot::new(1234567890L)
  .add_timing("request", 1500L, [])
  .add_benchmark(result)

let json = snap.to_json()           // → JSON string
let restored = @lib.Snapshot::from_json(json)  // → deserialize
```

#### CompositeReporter — multi-output

```moonbit
let composite = @lib.CompositeReporter::new()
let console = @lib.ConsoleReporter::new()
let json = @lib.JsonReporter::new()

composite.add_console(console)
composite.add_json(json)

// Single call → Console + JSON simultaneously
composite.report_stopwatch("task", 1500L, [])
println(json.output())
```

## Examples

- [basic_usage](examples/basic_usage/) — Basic usage + ConsoleReporter
- [lap_demo](examples/lap_demo/) — Lap timing + ConsoleReporter
- [bench_demo](examples/bench_demo/) — Benchmark + ConsoleReporter + JsonReporter
- [async_timer_demo](examples/async_timer_demo/) — Async timing + JsonReporter
- [span_demo](examples/span_demo/) — Span tree + ConsoleReporter + JsonReporter
- [regression_demo](examples/regression_demo/) — Regression detection + CompositeReporter
- [demo](demo/) — Comprehensive demo

Run examples:

```bash
moon run examples/basic_usage
moon run examples/lap_demo
moon run examples/bench_demo
moon run examples/async_timer_demo
moon run examples/span_demo
moon run examples/regression_demo
moon run demo
```

## Use Cases

- **Business code instrumentation**: record multi-phase timing in service processing flows (e.g. HTTP request handling chains)
- **Multi-flow phase observation**: use `PhaseTimer` / `Span` to observe performance distribution across pipeline stages
- **Async task timing**: `AsyncTimer` measures the execution time of coroutines / async tasks
- **Continuous regression detection**: `BaselineStore` + `RegressionDetector` compare against baselines to automatically spot performance regressions
- **Observability data export**: `Snapshot` + `JsonReporter` persist runtime metrics for external charting and analysis

## CLI Tool

The project ships a CLI demo program that showcases timing, laps, and formatting:

```bash
moon run src/cli -- --demo
```

## Development

```bash
# Build
moon build

# Test
moon test

# CLI tool
moon run src/cli -- --demo
```

## Project Stats

| Metric | Value |
|--------|-------|
| Unit tests | 138 (full coverage: normal flow + edge cases) |
| Source size | ~4,000+ LOC |
| External deps | MoonBit standard library only (zero third-party deps) |

## License

[MIT](LICENSE) © 2026 668xin
