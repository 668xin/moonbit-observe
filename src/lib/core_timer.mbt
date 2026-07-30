///|
/// 计时器状态
pub enum StopwatchState {
  Idle
  Running
  Paused
}

///|
/// Stopwatch 秒表核心类型
///
/// 支持注入自定义时钟函数，默认使用 SystemClock
pub struct Stopwatch {
  priv state : StopwatchState
  priv start_ts : Int64
  priv pause_acc : Int64
  priv lap_records : Array[LapRecord]
  priv now_fn : () -> Int64
}

///|
/// 创建未启动的计时器实例（默认系统时钟）
pub fn Stopwatch::new() -> Stopwatch {
  { state: Idle, start_ts: 0L, pause_acc: 0L, lap_records: [], now_fn: fn() { @env.now().reinterpret_as_int64() * 1_000_000L } }
}

///|
/// 创建未启动的计时器实例（使用自定义时钟函数）
pub fn Stopwatch::new_with_clock(now_fn : () -> Int64) -> Stopwatch {
  { state: Idle, start_ts: 0L, pause_acc: 0L, lap_records: [], now_fn }
}

///|
/// 创建未启动的计时器实例（使用 ClockProvider）
pub fn Stopwatch::new_with_provider(provider : ClockProvider) -> Stopwatch {
  Stopwatch::new_with_clock(fn() { provider.now() })
}

///|
/// 获取当前纳秒时间（使用注入的时钟函数）
fn Stopwatch::now(self : Stopwatch) -> Int64 {
  (self.now_fn)()
}

///|
/// 启动计时器，返回新的实例
pub fn Stopwatch::start(self : Stopwatch) -> Stopwatch {
  match self.state {
    Idle | Paused => {
      let now = self.now()
      { ..self, state: Running, start_ts: now }
    }
    Running => self
  }
}

///|
/// 暂停计时器，返回新的实例
pub fn Stopwatch::stop(self : Stopwatch) -> Stopwatch {
  match self.state {
    Running => {
      let now = self.now()
      let acc = self.pause_acc + (now - self.start_ts)
      { ..self, state: Paused, pause_acc: acc }
    }
    Idle | Paused => self
  }
}

///|
/// 恢复计时器，返回新的实例
pub fn Stopwatch::resume(self : Stopwatch) -> Stopwatch {
  match self.state {
    Paused => {
      let now = self.now()
      { ..self, state: Running, start_ts: now }
    }
    Idle | Running => self
  }
}

///|
/// 重置计时器，返回新的实例
pub fn Stopwatch::reset(_self : Stopwatch) -> Stopwatch {
  Stopwatch::new_with_clock(_self.now_fn)
}

///|
/// 计算当前累计纳秒
pub fn Stopwatch::elapsed_nanos(self : Stopwatch) -> Int64 {
  match self.state {
    Running => {
      let now = self.now()
      self.pause_acc + (now - self.start_ts)
    }
    Paused => self.pause_acc
    Idle => 0L
  }
}

///|
/// 获取当前累计耗时（微秒）
pub fn Stopwatch::elapsed_micros(self : Stopwatch) -> Int64 {
  self.elapsed_nanos() / 1000L
}

///|
/// 获取当前累计耗时（毫秒）
pub fn Stopwatch::elapsed_millis(self : Stopwatch) -> Int64 {
  self.elapsed_nanos() / 1_000_000L
}

///|
/// 获取当前累计耗时（秒，浮点数）
pub fn Stopwatch::elapsed_secs(self : Stopwatch) -> Double {
  let nanos = self.elapsed_nanos().to_double()
  nanos / 1_000_000_000.0
}

///|
/// 记录一个分段，返回 (新实例, LapRecord)
pub fn Stopwatch::lap(self : Stopwatch, label : String) -> (Stopwatch, LapRecord) {
  let now = self.now()
  let current_split = match self.state {
    Running => self.pause_acc + (now - self.start_ts)
    _ => self.pause_acc
  }
  let prev_total = if self.lap_records.length() > 0 {
    self.lap_records[self.lap_records.length() - 1].total_nanos
  } else {
    0L
  }
  let lap_nanos = current_split - prev_total
  let record = LapRecord::{ label, lap_nanos, total_nanos: current_split }
  let sw = { ..self, lap_records: self.lap_records + [record] }
  (sw, record)
}

///|
/// 获取所有分段记录
pub fn Stopwatch::list_laps(self : Stopwatch) -> Array[LapRecord] {
  self.lap_records
}

///|
/// 清空所有分段记录，返回新实例
pub fn Stopwatch::clear_laps(self : Stopwatch) -> Stopwatch {
  { ..self, lap_records: [] }
}

///|
/// 返回是否正在运行
pub fn Stopwatch::is_running(self : Stopwatch) -> Bool {
  match self.state {
    Running => true
    _ => false
  }
}

///|
/// 返回分段数量
pub fn Stopwatch::lap_count(self : Stopwatch) -> Int {
  self.lap_records.length()
}

///|
/// 返回格式化的耗时字符串（便捷方法）
pub fn Stopwatch::elapsed_fmt(self : Stopwatch) -> String {
  format_nanos(self.elapsed_nanos())
}
