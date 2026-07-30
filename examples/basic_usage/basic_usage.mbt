///|
/// 秒表基本使用示例（含 Reporter）
fn main {
  println("=== stopwatch 基本使用示例 ===")
  println("")

  // 1. 创建一个未启动的秒表
  let sw = @lib.Stopwatch::new()
  println("1. 创建秒表，is_running: " + sw.is_running().to_string())

  // 2. 启动秒表
  let sw1 = sw.start()
  println("2. 启动秒表，is_running: " + sw1.is_running().to_string())

  // 3. 读取耗时（纳秒、微秒、毫秒、秒）
  println("3. 耗时读取：")
  println("   nanos: " + sw1.elapsed_nanos().to_string())
  println("   micros: " + sw1.elapsed_micros().to_string())
  println("   millis: " + sw1.elapsed_millis().to_string())
  println("   secs: " + sw1.elapsed_secs().to_string())
  println("   格式化: " + @lib.format_nanos(sw1.elapsed_nanos()))

  // 4. 暂停秒表
  let sw2 = sw1.stop()
  println("4. 暂停，is_running: " + sw2.is_running().to_string())
  let paused_nanos = sw2.elapsed_nanos()
  println("   暂停时耗时: " + @lib.format_nanos(paused_nanos))

  // 5. 恢复秒表
  let sw3 = sw2.resume()
  println("5. 恢复，is_running: " + sw3.is_running().to_string())

  // 6. 重置秒表
  let sw4 = sw3.reset()
  println("6. 重置后 nanos: " + sw4.elapsed_nanos().to_string())
  println("   is_running: " + sw4.is_running().to_string())

  // 7. 使用 ConsoleReporter 输出
  println("")
  println("7. ConsoleReporter 输出：")
  let reporter = @lib.ConsoleReporter::new()
  reporter.report_stopwatch("basic-demo", paused_nanos, [])

  println("")
  println("=== 示例结束 ===")
}
