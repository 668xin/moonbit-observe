# moonbit-observe

一个轻量级、高性能的运行时计时与指标观测 SDK，使用 [MoonBit](https://www.moonbitlang.com/) 语言构建。支持**精确计时**、**分段计时（Lap）**、**暂停/恢复**、**基准测试**和**JSON导出**等功能。

## 项目简介

moonbit-observe 是面向 MoonBit 生态原创开发的通用运行时计时器与指标观测工具库。

当前生态缺少开箱即用、支持分段打点的标准化观测组件。开发者在业务程序、脚本、服务中进行耗时观测时，只能手动编写临时计时代码，缺少多阶段打点、异步任务计时、人性化时间格式化等能力。

本项目核心定位为**运行时埋点计时观测工具**，服务应用开发过程中多阶段耗时统计、流程耗时观测；简易基准测试能力仅作为附属可选功能，并非项目核心。

> 与已有 moonbench 差异化说明：
> moonbench 面向 `moon bench`，专注源码内单元式基准测试、CI 性能比对；
> moonbit-observe 面向程序运行时动态计时，核心能力为 Stopwatch、分段Lap打点、异步任务计时，适用于业务代码埋点、多流程分段耗时观测，二者使用场景、核心目标完全不同。

库完全基于 MoonBit 标准库构建，无重型外部依赖，可直接作为公共依赖引入任意 MoonBit 项目；同时提供 feature 开关，可选接入 moonbitlang/async 生态实现异步计时。

## 核心功能范围

- 实现完整 Stopwatch 计时器实例：支持启动、暂停、恢复、重置操作；
- 多精度时间读取接口：获取纳秒、微秒、毫秒、秒级耗时原始数值；
- 分段打点（Lap）能力：支持命名分段计时，保存每一段耗时与时间戳；
- 智能时间格式化工具：自动适配最优时间单位，输出可读性友好的耗时文本；
- 适配 `moonbitlang/async`，提供异步任务专用计时 API（条件编译可选特性）；
- 简易基准测试运行器（可选附属模块）：支持函数循环执行、基础耗时统计；
- 基准测试结果 JSON 序列化导出（附属功能）；
- 完善非法状态边界处理，规避重复启停、未启动恢复等异常调用；
- 报告器系统：ConsoleReporter / JsonReporter / CompositeReporter 多路输出；
- 快照系统：Snapshot 时间点状态捕获，支持 JSON 序列化与反序列化；
- 编写完整单元测试，覆盖全部API分支、边界场景；
- 提供多组可运行示例代码：基础计时、分段打点、异步任务计时；
- 完善 README 文档，包含快速上手、API示例、使用场景说明；
- 提供命令行示例程序，直观展示计时器使用效果。

## 快速开始

```moonbit
fn main {
  // 创建秒表
  let sw = @lib.Stopwatch::new()

  // 启动
  let sw1 = sw.start()

  // 读取耗时
  println("纳秒: {sw1.elapsed_nanos()}")
  println("毫秒: {sw1.elapsed_millis()}")
  println("格式化: {sw1.elapsed_fmt()}")

  // 暂停
  let sw2 = sw1.stop()

  // 恢复
  let sw3 = sw2.resume()

  // 重置
  let sw4 = sw3.reset()
}
```

## API 概览

### 核心类型 `Stopwatch`

```
┌─ Stopwatch ──────────────────────────────┐
│  Stopwatch::new()       创建未启动秒表     │
│  .start()               启动              │
│  .stop()                暂停              │
│  .resume()              恢复              │
│  .reset()               重置              │
│  .elapsed_nanos()       纳秒              │
│  .elapsed_micros()      微秒              │
│  .elapsed_millis()      毫秒              │
│  .elapsed_secs()        秒（浮点数）       │
│  .elapsed_fmt()         可读字符串         │
│  .is_running()          是否运行中         │
│  .lap(label)            记录分段           │
│  .list_laps()           获取所有分段       │
│  .clear_laps()          清空分段           │
│  .lap_count()           分段数量           │
└──────────────────────────────────────────┘
```

### 分段记录 `LapRecord`

```moonbit
pub struct LapRecord {
  label       : String   // 分段标签
  lap_nanos   : Int64    // 本段耗时（纳秒）
  total_nanos : Int64    // 累计耗时（纳秒）
}
```

### 基准测试

```moonbit
// 创建配置：预热5次，正式运行10次
let config = @lib.BenchmarkConfig::new(5, 10)
let runner = @lib.BenchmarkRunner::new(config)
let result = runner.run(fn() { /* 被测函数 */ })

// 打印结果
@lib.print_table(result)

// JSON 导出
let json = @lib.result_to_json(result)
```

### 格式化函数

```moonbit
// 纳秒格式化：自动单位切换
@lib.format_nanos(1500L)        // → "1 μs"
@lib.format_nanos(1_500_000L)   // → "1.5 ms"
@lib.format_nanos(1_500_000_000L) // → "1.5 s"

// 时间格式化：HH:MM:SS.mmm
@lib.format_time(3661.123)      // → "01:01:01.123"
```

### 异步计时 `AsyncTimer`

```moonbit
let timer = @lib.AsyncTimer::new()
let timer = timer.start()
// ... async task ...
let (timer, elapsed_ns) = timer.stop()
```

### 统计引擎

```moonbit
// StatisticalSummary — 累加式计算
let summary = @lib.StatisticalSummary::new()
  .add(100L).add(200L).add(300L)

// 均值 / 方差 / 标准差
summary.mean()    // → Some(200)
summary.variance() // → Some(10000)
summary.stddev()   // → Some(100)

// 滑动窗口 — 固定容量环形缓冲
let window = @lib.SlidingWindow::new(5)
  .add(50L).add(10L).add(30L).add(20L).add(40L)
window.median() // → Some(30)

// 对数直方图 — P50/P90/P99 分位数
let hist = @lib.LogHistogram::new()
  .record(100L).record(200L).record(300L)
hist.percentile(50) // → P50
```

### 基线持久化 & 退化检测

```moonbit
// 记录基线
let summary = @lib.StatisticalSummary::new().add(100L).add(200L)
let store = @lib.BaselineStore::new().add("compute_task", summary)

// 检测退化（阈值 110%）
let detector = @lib.RegressionDetector::new(store, 110)
let current = @lib.StatisticalSummary::new().add(180L)
match detector.detect("compute_task", current) {
  Some(r) => if r.is_regression() { println("性能退化！") }
  None => println("无基线数据")
}
```

### Span 嵌套阶段计时

```moonbit
let parent = @lib.Span::new("request_handler").start()
let child = @lib.Span::new("db_query").start()
let child = child.stop()
let parent = parent.add_child(child).stop()
parent.total_elapsed_nanos() // 含子树累计
```

### PhaseTimer 连续阶段计时

```moonbit
let pt = @lib.PhaseTimer::new()
  .begin_phase("receive")
  .begin_phase("process")  // 自动结束 receive
  .begin_phase("respond")  // 自动结束 process
  .end_phase()
pt.phases().length() // → 3
pt.total_elapsed_nanos()
```

### 报告器系统 `Reporter`

#### ConsoleReporter（控制台输出）

```moonbit
let reporter = @lib.ConsoleReporter::new()
reporter.report_stopwatch("request", 1500000L, [])
// 输出: === Stopwatch Report ===
//         Name: request
//         Elapsed: 1.5 ms

// 可选单位 / 是否显示分段 / 是否显示标题
let reporter = @lib.ConsoleReporter::with_options(
  @lib.TimeUnit::milliseconds(), false, true,
)
```

#### JsonReporter（JSON 序列化）

```moonbit
let reporter = @lib.JsonReporter::new()
reporter.report_stopwatch("api", 1500L, [])
reporter.report_benchmark(result)
println(reporter.output())
// 输出: [{"type":"stopwatch","name":"api",...},...]
reporter.reset()  // 清空累积
```

#### Snapshot（快照 — 时间点状态捕获）

```moonbit
let snap = @lib.Snapshot::new(1234567890L)
  .add_timing("request", 1500L, [])
  .add_benchmark(result)

let json = snap.to_json()           // → JSON 字符串
let restored = @lib.Snapshot::from_json(json)  // → 反序列化
```

#### CompositeReporter（多路输出）

```moonbit
let composite = @lib.CompositeReporter::new()
let console = @lib.ConsoleReporter::new()
let json = @lib.JsonReporter::new()

composite.add_console(console)  // 添加 Console 输出
composite.add_json(json)        // 同时添加 JSON 输出

// 一次调用同时输出到 Console + JSON
composite.report_stopwatch("task", 1500L, [])
println(json.output())
```

## 完整示例

- [basic_usage](examples/basic_usage/) — Stopwatch 基本使用 + ConsoleReporter
- [lap_demo](examples/lap_demo/) — 分段计时演示 + ConsoleReporter
- [bench_demo](examples/bench_demo/) — 基准测试演示 + ConsoleReporter + JsonReporter
- [async_timer_demo](examples/async_timer_demo/) — 异步任务计时 + JsonReporter
- [span_demo](examples/span_demo/) — Span 树 + ConsoleReporter + JsonReporter
- [regression_demo](examples/regression_demo/) — 性能退化检测 + CompositeReporter
- [demo](demo/) — 综合演示

运行示例：

```bash
moon run examples/basic_usage
moon run examples/lap_demo
moon run examples/bench_demo
moon run examples/async_timer_demo
moon run examples/span_demo
moon run examples/regression_demo
moon run demo
```

## 开发

```bash
# 构建
moon build

# 测试
moon test

# 命令行工具
moon run src/cli -- --demo
```

## 许可证

[MIT](LICENSE) © 2026 668xin
