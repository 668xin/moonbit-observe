///|
/// Bucket — 直方图桶
pub struct Bucket {
  priv label : String
  priv count : Int64
}

///|
pub fn Bucket::label(self : Bucket) -> String { self.label }
pub fn Bucket::count(self : Bucket) -> Int64 { self.count }

///|
/// LogHistogram — 简易对数直方图
///
/// 按对数刻度分桶（2^n 边界），覆盖纳秒~秒级范围。
/// 支持 P50/P90/P99/P99.9 分位数估算。
pub struct LogHistogram {
  priv buckets : Array[Int64]
  priv total : Int64
  // Precomputed bucket upper bounds: [1, 2, 4, 8, ..., 2^60]
  priv bounds : Array[Int64]
  priv max_val : Int64
}

///|
pub fn LogHistogram::new() -> LogHistogram {
  // Create 60 log-scale buckets: [1,2,4,8,...2^59] covering ns to ~36 years
  let buk = Array::make(60, 0L)
  let bnd = Array::make(60, 0L)
  let mut v = 1L
  let mut i = 0
  while i < 60 {
    bnd[i] = v
    v = v * 2L
    i = i + 1
  }
  { buckets: buk, total: 0L, bounds: bnd, max_val: 0L }
}

///|
/// 记录一个值
pub fn LogHistogram::record(self : LogHistogram, value : Int64) -> LogHistogram {
  if value < 0L { return self }
  let buk = self.buckets
  let idx = self.find_bucket(value)
  buk[idx] = buk[idx] + 1L
  let new_max = if value > self.max_val { value } else { self.max_val }
  { ..self, buckets: buk, total: self.total + 1L, max_val: new_max }
}

fn LogHistogram::find_bucket(self : LogHistogram, value : Int64) -> Int {
  // binary search for the smallest bound >= value
  if value <= 1L { return 0 }
  let mut lo = 0
  let mut hi = self.bounds.length() - 1
  while lo < hi {
    let mid = (lo + hi) / 2
    if self.bounds[mid] >= value {
      hi = mid
    } else {
      lo = mid + 1
    }
  }
  lo
}

///|
/// 获取分位数估计
///
/// percentile: 0~100 例如 50 表示 P50
pub fn LogHistogram::percentile(self : LogHistogram, percentile : Int) -> Int64? {
  if self.total == 0L { return None }
  if percentile <= 0 { return Some(0L) }
  if percentile >= 100 { return Some(self.max_val) }
  let target = self.total * (percentile.to_int64()) / 100L
  let mut cum = 0L
  let mut i = 0
  while i < self.buckets.length() {
    cum = cum + self.buckets[i]
    if cum > target {
      return Some(self.bounds[i])
    }
    i = i + 1
  }
  Some(self.max_val)
}

///|
/// 获取所有桶（仅非空桶）
pub fn LogHistogram::buckets(self : LogHistogram) -> Array[Bucket] {
  let mut result : Array[Bucket] = []
  let mut i = 0
  while i < self.buckets.length() {
    if self.buckets[i] > 0L {
      let label = "< " + self.bounds[i].to_string()
      result = result + [Bucket::{ label, count: self.buckets[i] }]
    }
    i = i + 1
  }
  result
}

///|
pub fn LogHistogram::total_count(self : LogHistogram) -> Int64 {
  self.total
}

///|
pub fn LogHistogram::max_value(self : LogHistogram) -> Int64 {
  self.max_val
}

///|
pub fn LogHistogram::min_value(self : LogHistogram) -> Int64? {
  let mut i = 0
  while i < self.buckets.length() {
    if self.buckets[i] > 0L {
      return Some(self.bounds[i] / 2L)
    }
    i = i + 1
  }
  None
}
