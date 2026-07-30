///|
/// RegressionDetector 性能退化检测 + Reporter 示例
///
/// 演示 BaselineStore + RegressionDetector + Snapshot + CompositeReporter
fn main {
  println("=== 性能退化检测示例 ===")
  println("")

  // 1. 创建基线存储并添加基线数据
  let baseline = @lib.BaselineStore::new()
  let stat1 = @lib.StatisticalSummary::new()
    .add(100L).add(110L).add(90L)
  let base1 = baseline.add("query-users", stat1)
  println("基线: query-users, mean=" + stat1.mean().to_string())

  // 2. 创建退化检测器（阈值 120%，即超过基线 20% 视为退化）
  let detector = @lib.RegressionDetector::new(base1, 120L)

  // 3. 当前测试结果
  let cur_stat = @lib.StatisticalSummary::new()
    .add(150L).add(160L).add(140L)
  println("当前: query-users, mean=" + cur_stat.mean().to_string())

  // 4. 检测退化
  let result = detector.detect("query-users", cur_stat)
  match result {
    None => println("未找到基线记录")
    Some(r) => {
      println("退化检测结果:")
      println("  基线均值: " + r.baseline_mean().to_string() + " ns")
      println("  当前均值: " + r.current_mean().to_string() + " ns")
      println("  比值: " + r.ratio().to_string() + "%")
      println("  是否退化: " + r.is_regression().to_string())
    }
  }

  // 5. 创建 Snapshot 保存当前状态
  let snapshot = @lib.Snapshot::new(1234567890L)
    .add_timing("query-users", 150L, [])

  // 6. 使用 CompositeReporter 同时输出到 Console 和 JSON
  let composite = @lib.CompositeReporter::new()
  let console = @lib.ConsoleReporter::new()
  let json = @lib.JsonReporter::new()
  composite.add_console(console)
  composite.add_json(json)

  composite.report_snapshot(snapshot)

  println("Composite JSON output:")
  println(json.output())

  // 7. 演示 Snapshot 序列化/反序列化
  let snap_json = snapshot.to_json()
  println("")
  println("Snapshot JSON:")
  println(snap_json)

  let restored = @lib.Snapshot::from_json(snap_json)
  println("反序列化条目数: " + restored.entry_count().to_string())

  println("")
  println("=== 示例结束 ===")
}
