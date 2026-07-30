# moonbit-observe

A lightweight, high-performance runtime timing and metrics observation SDK built with [MoonBit](https://www.moonbitlang.com/). Supports **precise timing**, **lap timing**, **pause/resume**, **benchmarking**, and **JSON export**.

## Features

- **High-precision timing** — nanosecond resolution, with convenience methods for micro/milli/seconds
- **Pause/Resume** — pause anytime and resume to accumulate elapsed time
- **Lap timing** — record labeled lap splits with automatic accumulation
- **Benchmarking** — built-in warmup + multiple runs + statistical analysis
- **Formatting** — auto unit switching (ns / μs / ms / s)
- **JSON export** — serialize benchmark results to JSON
- **Async timer** — `AsyncTimer` wrapper for async task timing
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

### Async Timer `AsyncTimer`

```moonbit
let timer = @lib.AsyncTimer::new()
let timer = timer.start()
// ... async task ...
let (timer, elapsed_ns) = timer.stop()
```

## Examples

- [basic_usage](examples/basic_usage/) — Basic stopwatch usage
- [lap_demo](examples/lap_demo/) — Lap timing demo
- [bench_demo](examples/bench_demo/) — Benchmark demo
- [demo](demo/) — Comprehensive demo (including format_time)

Run examples:

```bash
moon run examples/basic_usage
moon run examples/lap_demo
moon run examples/bench_demo
moon run demo
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

## License

[MIT](LICENSE) © 2026 668xin
