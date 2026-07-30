///|
/// TimeUnit — 时间单位选择
pub enum TimeUnit {
  Auto
  Nanoseconds
  Microseconds
  Milliseconds
  Seconds
}

///|
/// 格式化纳秒为指定单位
pub fn format_nanos_with_unit(nanos : Int64, unit : TimeUnit) -> String {
  match unit {
    Auto => format_nanos(nanos)
    Nanoseconds => nanos.to_string() + " ns"
    Microseconds => (nanos / 1000L).to_string() + " μs"
    Milliseconds => {
      let ms_val = nanos.to_double() / 1_000_000.0
      let ms = (ms_val * 100.0).floor() / 100.0
      ms.to_string() + " ms"
    }
    Seconds => {
      let s_val = nanos.to_double() / 1_000_000_000.0
      let s = (s_val * 100.0).floor() / 100.0
      s.to_string() + " s"
    }
  }
}
