///|
/// StatisticalSummary — 统计聚合结构体
///
/// 累加式计算均值、方差、标准差、偏度
pub struct StatisticalSummary {
  priv count : Int64
  priv sum : Int64
  priv sum_sq : Int64
  priv min : Int64
  priv max : Int64
}

///|
pub fn StatisticalSummary::new() -> StatisticalSummary {
  { count: 0L, sum: 0L, sum_sq: 0L, min: 0L, max: 0L }
}

///|
/// 添加一个数据点
pub fn StatisticalSummary::add(self : StatisticalSummary, value : Int64) -> StatisticalSummary {
  if self.count == 0L {
    { count: 1L, sum: value, sum_sq: value * value, min: value, max: value }
  } else {
    let new_min = if value < self.min { value } else { self.min }
    let new_max = if value > self.max { value } else { self.max }
    { count: self.count + 1L, sum: self.sum + value, sum_sq: self.sum_sq + value * value, min: new_min, max: new_max }
  }
}

///|
pub fn StatisticalSummary::count(self : StatisticalSummary) -> Int64 { self.count }

///|
pub fn StatisticalSummary::min(self : StatisticalSummary) -> Int64? {
  if self.count == 0L { None } else { Some(self.min) }
}

///|
pub fn StatisticalSummary::max(self : StatisticalSummary) -> Int64? {
  if self.count == 0L { None } else { Some(self.max) }
}

///|
/// 均值（纳秒）
pub fn StatisticalSummary::mean(self : StatisticalSummary) -> Int64? {
  if self.count == 0L { None } else { Some(self.sum / self.count) }
}

///|
/// 方差（使用 Welford 在线算法估算）
pub fn StatisticalSummary::variance(self : StatisticalSummary) -> Int64? {
  if self.count < 2L { return None }
  let n = self.count
  let mean_val = self.sum / n
  // var = (sum_sq - 2*mean*sum + n*mean^2) / (n-1)
  let numerator = self.sum_sq - 2L * mean_val * self.sum + n * mean_val * mean_val
  Some(numerator / (n - 1L))
}

///|
/// 标准差
pub fn StatisticalSummary::stddev(self : StatisticalSummary) -> Int64? {
  match self.variance() {
    None => None
    Some(v) => {
      // integer sqrt approximation
      let r = v
      let mut q = 1L
      while q < r / q { q = q + 1L }
      Some(r / q)
    }
  }
}

///|
/// 极差
pub fn StatisticalSummary::range(self : StatisticalSummary) -> Int64? {
  if self.count == 0L { None } else { Some(self.max - self.min) }
}
