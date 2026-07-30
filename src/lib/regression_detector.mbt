///|
/// RegressionResult — 退化检测结果
pub struct RegressionResult {
  priv name : String
  priv baseline_mean : Int64
  priv current_mean : Int64
  priv ratio : Int64  // 百分比，如 120 表示慢了 20%
  priv is_regression : Bool
  priv threshold_pct : Int64
}

///|
pub fn RegressionResult::name(self : RegressionResult) -> String { self.name }
pub fn RegressionResult::baseline_mean(self : RegressionResult) -> Int64 { self.baseline_mean }
pub fn RegressionResult::current_mean(self : RegressionResult) -> Int64 { self.current_mean }
pub fn RegressionResult::ratio(self : RegressionResult) -> Int64 { self.ratio }
pub fn RegressionResult::is_regression(self : RegressionResult) -> Bool { self.is_regression }
pub fn RegressionResult::threshold_pct(self : RegressionResult) -> Int64 { self.threshold_pct }

///|
/// RegressionDetector — 性能退化检测器
///
/// 对比当前测试结果与基线，检测性能退化。
pub struct RegressionDetector {
  priv store : BaselineStore
  priv threshold_percent : Int64  // 如 110 表示超过基线 10% 视为退化
}

///|
pub fn RegressionDetector::new(store : BaselineStore, threshold_percent : Int64) -> RegressionDetector {
  { store, threshold_percent }
}

///|
/// 检测退化（传入结果名称和当前统计）
pub fn RegressionDetector::detect(self : RegressionDetector, name : String, current : StatisticalSummary) -> RegressionResult? {
  let baseline = self.store.get(name)
  match baseline {
    None => None
    Some(b) => match current.mean() {
      None => None
      Some(cur_mean) => {
        let ratio = if b.mean_nanos == 0L { 100L } else { cur_mean * 100L / b.mean_nanos }
        let is_reg = ratio > self.threshold_percent
        Some(RegressionResult::{ name, baseline_mean: b.mean_nanos, current_mean: cur_mean, ratio, is_regression: is_reg, threshold_pct: self.threshold_percent })
      }
    }
  }
}

///|
/// 获取退化阈值百分比
pub fn RegressionDetector::threshold_percent(self : RegressionDetector) -> Int64 {
  self.threshold_percent
}
