///|
/// 基准测试配置
pub struct BenchmarkConfig {
  priv warmup_times : Int
  priv run_times : Int
}

///|
/// 获取预热次数
pub fn BenchmarkConfig::warmup_times(self : BenchmarkConfig) -> Int {
  self.warmup_times
}

///|
/// 获取运行次数
pub fn BenchmarkConfig::run_times(self : BenchmarkConfig) -> Int {
  self.run_times
}

///|
/// 基准测试结果（单位均为纳秒）
pub struct BenchmarkResult {
  priv min_nanos : Int64
  priv max_nanos : Int64
  priv avg_nanos : Int64
  priv total_nanos : Int64
}

///|
/// 获取最小耗时（纳秒）
pub fn BenchmarkResult::min_nanos(self : BenchmarkResult) -> Int64 {
  self.min_nanos
}

///|
/// 获取最大耗时（纳秒）
pub fn BenchmarkResult::max_nanos(self : BenchmarkResult) -> Int64 {
  self.max_nanos
}

///|
/// 获取平均耗时（纳秒）
pub fn BenchmarkResult::avg_nanos(self : BenchmarkResult) -> Int64 {
  self.avg_nanos
}

///|
/// 获取总耗时（纳秒）
pub fn BenchmarkResult::total_nanos(self : BenchmarkResult) -> Int64 {
  self.total_nanos
}

///|
/// 创建 BenchmarkResult（用于反序列化等场景）
pub fn BenchmarkResult::new(min_nanos : Int64, max_nanos : Int64, avg_nanos : Int64, total_nanos : Int64) -> BenchmarkResult {
  { min_nanos, max_nanos, avg_nanos, total_nanos }
}

///|
/// 创建基准测试配置
///
/// 参数边界保护：run_times 非正数时给出友好提示并设为 1
pub fn BenchmarkConfig::new(warmup : Int, run_times : Int) -> BenchmarkConfig {
  if run_times <= 0 {
    println("Warning: run_times must be > 0, got " + run_times.to_string() + ", defaulting to 1")
    BenchmarkConfig::{ warmup_times: warmup, run_times: 1 }
  } else {
    BenchmarkConfig::{ warmup_times: warmup, run_times }
  }
}

///|
/// 基准测试运行器
pub struct BenchmarkRunner {
  priv config : BenchmarkConfig
}

///|
/// 创建基准测试运行器
pub fn BenchmarkRunner::new(config : BenchmarkConfig) -> BenchmarkRunner {
  BenchmarkRunner::{ config }
}

///|
/// 运行基准测试
///
/// 先执行预热迭代，再执行正式迭代并统计耗时
pub fn BenchmarkRunner::run(self : BenchmarkRunner, func : () -> Unit) -> BenchmarkResult {
  // 预热
  let warmup = self.config.warmup_times
  for _i in 0..<warmup {
    func()
  }

  // 正式测试
  let n = self.config.run_times
  let mut min_nanos = 0L
  let mut max_nanos = 0L
  let mut total_nanos = 0L
  let mut first = true

  for _i in 0..<n {
    let start = @env.now().reinterpret_as_int64() * 1_000_000L
    func()
    let end = @env.now().reinterpret_as_int64() * 1_000_000L
    let elapsed = end - start
    total_nanos = total_nanos + elapsed
    if first {
      min_nanos = elapsed
      max_nanos = elapsed
      first = false
    } else {
      if elapsed < min_nanos { min_nanos = elapsed }
      if elapsed > max_nanos { max_nanos = elapsed }
    }
  }

  let avg_nanos = total_nanos / n.to_int64()

  BenchmarkResult::{ min_nanos, max_nanos, avg_nanos, total_nanos }
}

///|
/// 控制台打印基准测试结果
pub fn print_table(result : BenchmarkResult) -> Unit {
  println("Benchmark Result")
  println("  Min:   " + format_nanos(result.min_nanos))
  println("  Max:   " + format_nanos(result.max_nanos))
  println("  Avg:   " + format_nanos(result.avg_nanos))
  println("  Total: " + format_nanos(result.total_nanos))
}
