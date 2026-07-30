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
