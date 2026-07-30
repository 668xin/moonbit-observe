///|
/// 秒表命令行工具
///
/// Usage:
///   stopwatch [options]
///
/// Options:
///   --demo               运行演示
///   --help, -h           显示帮助信息
fn main {
  let args = @env.args()
  let mut show_demo = false
  let mut show_help = false
  let mut i = 1

  while i < args.length() {
    let arg = args[i]
    if arg == "--demo" {
      show_demo = true
    } else if arg == "--help" || arg == "-h" {
      show_help = true
    }
    i = i + 1
  }

  if show_help || args.length() <= 1 {
    print_usage()
    return
  }

  if show_demo {
    run_demo()
  }
}

///|
/// 运行秒表演示
fn run_demo() -> Unit {
  println("=== MoonBit Stopwatch Demo ===")
  println("")

  let sw = @lib.Stopwatch::new()
  println("Created stopwatch: idle")
  println("Elapsed nanos: " + sw.elapsed_nanos().to_string())
  println("")

  let sw1 = sw.start()
  println("Started: running = " + sw1.is_running().to_string())

  let elapsed1 = sw1.elapsed_secs()
  println("Elapsed secs: " + elapsed1.to_string())
  println("Formatted: " + @lib.format_nanos(sw1.elapsed_nanos()))
  println("")

  let (sw2, lap1) = sw1.lap("demo-lap")
  println("Lap recorded: " + @lib.format_nanos(lap1.lap_nanos()))
  println("Total laps: " + sw2.lap_count().to_string())
  println("")

  let sw3 = sw2.stop()
  println("Stopped: running = " + sw3.is_running().to_string())
  println("Final elapsed: " + @lib.format_nanos(sw3.elapsed_nanos()))
  println("")

  let sw4 = sw3.reset()
  println("Reset: elapsed_nanos = " + sw4.elapsed_nanos().to_string())
  println("Laps after reset: " + sw4.lap_count().to_string())
  println("")
  println("=== Demo Complete ===")
}

///|
/// 打印使用帮助
fn print_usage() -> Unit {
  println("moonbit-observe - MoonBit Observe CLI Tool")
  println("")
  println("Usage:")
  println("  stopwatch [options]")
  println("")
  println("Options:")
  println("  --demo          Run stopwatch demo")
  println("  --help, -h      Show this help")
  println("")
  println("Examples:")
  println("  stopwatch --demo")
}
