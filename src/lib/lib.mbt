///|
/// lib 包 — 统一导出入口
///
/// 本包公开以下 API：
///
/// 时钟抽象：
///   Clock trait            - 时钟接口
///   SystemClock            - 系统时钟实现
///   ClockProvider          - 时钟提供者（可注入）
///   ClockBackwardDetector  - 时钟回退检测
///   MockClock              - 虚拟时钟（用于测试）
///
/// 核心秒表：
///   Stopwatch       - 秒表核心类型，支持 启动/暂停/恢复/重置/分段计时
///   StopwatchState  - 秒表状态枚举（Idle / Running / Paused）
///   LapRecord       - 分段记录（label + lap_nanos + total_nanos）
///
/// 基准测试：
///   BenchmarkConfig   - 基准测试配置（预热次数 + 运行次数）
///   BenchmarkResult   - 基准测试结果（min/max/avg/total 纳秒）
///   BenchmarkRunner   - 基准测试运行器
///   print_table       - 控制台打印基准测试结果
///
/// 格式化：
///   format_nanos  - 纳秒格式化为可读字符串（ns / μs / ms / s）
///   format_time   - 秒数格式化为 HH:MM:SS.mmm
///
/// JSON 导出：
///   result_to_json  - BenchmarkResult → JSON 字符串
///
/// 异步计时：
///   AsyncTimer    - 异步任务计时器（基于 Stopwatch）
///
/// 标签与并发：
///   Tag               - 键值对标签
///   Tags              - 标签集合
///   TaggedStopwatch   - 携带标签的计时器
///   SharedStopwatch   - 共享计时器（多协程安全，带唯一 ID）
///
/// 链路计时：
///   Span       - 嵌套阶段计时（父子层次，自动累计子树耗时）
///   PhaseTimer - 连续命名阶段计时
///
/// 统计与直方图：
///   StatisticalSummary - 累加式统计（均值/方差/标准差/min/max/range）
///   SlidingWindow      - 固定容量滑动窗口（环形缓冲 + 中位数）
///   LogHistogram       - 对数直方图（P50/P90/P99 分位数）
///
/// 基线 & 回归检测：
///   BaselineStore     - 基线存储（JSON 序列化/反序列化）
///   RegressionDetector - 性能退化检测（可配置阈值百分比）
///
/// 报告器：
///   TimeUnit              - 时间单位枚举（Auto/Nanoseconds/Microseconds/Milliseconds/Seconds）
///   format_nanos_with_unit - 按指定单位格式化纳秒
///   ConsoleReporter       - 控制台格式化输出报告器
///   JsonReporter          - JSON 序列化报告器（可累积多报告输出）
///   CompositeReporter     - 多路报告组合器（支持 Console/Json 等混合输出）
///
/// 快照：
///   Snapshot        - 时间点快照（捕获计时状态，支持 JSON 序列化/反序列化）
///   SnapshotEntry   - 快照条目枚举（TimingEntry / BenchmarkEntry / SpanEntry）
