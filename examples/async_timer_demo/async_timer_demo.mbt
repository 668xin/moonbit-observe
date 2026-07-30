///|
/// AsyncTimer 异步任务计时示例
///
/// 演示 AsyncTimer + ConsoleReporter 的使用
fn main {
  println("=== AsyncTimer 异步任务计时示例 ===")
  println("")

  // 创建并启动 AsyncTimer
  let timer = @lib.AsyncTimer::new()
  let timer1 = timer.start()

  // 模拟异步任务（这里用空循环代替）
  let mut i = 0
  while i < 1000 {
    i = i + 1
  }

  // 停止计时
  let (timer2, elapsed) = timer1.stop()
  let name = "async-task-1"

  // 使用 ConsoleReporter 输出
  let reporter = @lib.ConsoleReporter::new()
  reporter.report_stopwatch(name, elapsed, [])

  // 测试重置
  let timer3 = timer2.reset()
  let timer4 = timer3.start()

  let mut j = 0
  while j < 500 {
    j = j + 1
  }

  let (_timer5, elapsed2) = timer4.stop()
  reporter.report_stopwatch("async-task-2", elapsed2, [])

  // 使用 JsonReporter 记录两次异步任务
  let json_reporter = @lib.JsonReporter::new()
  json_reporter.report_stopwatch("async-task-1", elapsed, [])
  json_reporter.report_stopwatch("async-task-2", elapsed2, [])
  println("JSON output:")
  println(json_reporter.output())

  println("=== 示例结束 ===")
}
