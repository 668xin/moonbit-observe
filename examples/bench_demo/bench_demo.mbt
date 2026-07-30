///|
/// Benchmark 基准测试示例（含 Reporter）
///
/// 使用 BenchmarkRunner 对 Stopwatch 的 new() 方法进行性能测试
fn main {
  // 创建配置：预热 3 次，正式运行 10 次
  let config = @lib.BenchmarkConfig::new(3, 10)
  let runner = @lib.BenchmarkRunner::new(config)

  // 创建一个用于基准测试的简单函数
  let func = fn() {
    let sw = @lib.Stopwatch::new()
    let _sw1 = sw.start()
  }

  // 运行基准测试
  let result = runner.run(func)

  // 使用 ConsoleReporter 输出
  let reporter = @lib.ConsoleReporter::new()
  reporter.report_benchmark(result)

  // 使用 JsonReporter 序列化
  let json_reporter = @lib.JsonReporter::new()
  json_reporter.report_benchmark(result)
  println("JSON output:")
  println(json_reporter.output())
}
