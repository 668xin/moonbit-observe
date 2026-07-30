///|
/// 分段计时（Lap）示例（含 Reporter）
fn main {
  println("=== 分段计时示例 ===")
  println("")

  // 创建一个秒表并启动
  let sw = @lib.Stopwatch::new().start()
  println("秒表已启动")

  // 记录第1圈
  let (sw1, lap1) = sw.lap("第1圈")
  println("1. 圈名: " + lap1.label())
  println("   分段: " + @lib.format_nanos(lap1.lap_nanos()))
  println("   累计: " + @lib.format_nanos(lap1.total_nanos()))

  // 记录第2圈
  let (sw2, lap2) = sw1.lap("第2圈")
  println("2. 圈名: " + lap2.label())
  println("   分段: " + @lib.format_nanos(lap2.lap_nanos()))
  println("   累计: " + @lib.format_nanos(lap2.total_nanos()))

  // 记录第3圈
  let (sw3, lap3) = sw2.lap("第3圈")
  println("3. 圈名: " + lap3.label())
  println("   分段: " + @lib.format_nanos(lap3.lap_nanos()))
  println("   累计: " + @lib.format_nanos(lap3.total_nanos()))

  // 列出所有分段
  println("")
  println("所有分段记录：")
  let laps = sw3.list_laps()
  let mut i = 0
  while i < laps.length() {
    let lap = laps[i]
    println(
      "  [" + lap.label() + "] 分段=" +
      @lib.format_nanos(lap.lap_nanos()) + ", 累计=" +
      @lib.format_nanos(lap.total_nanos()),
    )
    i = i + 1
  }

  println("")
  println("总圈数: " + sw3.lap_count().to_string())

  // 暂停秒表
  let sw4 = sw3.stop()
  let total_nanos = sw4.elapsed_nanos()

  println("最终耗时: " + @lib.format_nanos(total_nanos))

  // 使用 ConsoleReporter 展示分段详情
  println("")
  println("ConsoleReporter 分段输出：")
  let reporter = @lib.ConsoleReporter::new()
  reporter.report_stopwatch("lap-demo", total_nanos, sw3.list_laps())

  println("")
  println("=== 示例结束 ===")
}
