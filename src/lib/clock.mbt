///|
/// Clock trait — 时钟抽象接口
pub trait Clock {
  now_nanos(Self) -> Int64
}

///|
/// SystemClock — 基于 @env.now() 的系统时钟
pub struct SystemClock {}

pub impl Clock for SystemClock with fn now_nanos(_self : SystemClock) -> Int64 {
  @env.now().reinterpret_as_int64() * 1_000_000L
}

///|
/// ClockProvider — 时钟提供者，封装一个可更换的 Clock 实例
pub struct ClockProvider {
  priv clock : () -> Int64
}

pub fn ClockProvider::new(clock : () -> Int64) -> ClockProvider {
  { clock : clock, }
}

///|
/// 使用系统时钟创建 ClockProvider
pub fn ClockProvider::system() -> ClockProvider {
  ClockProvider::new(fn() { @env.now().reinterpret_as_int64() * 1_000_000L })
}

///|
/// 获取当前纳秒时间
pub fn ClockProvider::now(self : ClockProvider) -> Int64 {
  (self.clock)()
}

///|
/// ClockBackwardDetector — 时钟回退检测
pub struct ClockBackwardDetector {
  priv last_ts : Int64
  priv backward_count : Int64
}

pub fn ClockBackwardDetector::new() -> ClockBackwardDetector {
  { last_ts: 0L, backward_count: 0L }
}

///|
/// 检测时钟是否回退，返回 (当前时间, 是否回退)
pub fn ClockBackwardDetector::check(self : ClockBackwardDetector, now : Int64) -> (ClockBackwardDetector, Bool) {
  if now < self.last_ts {
    ({ last_ts: now, backward_count: self.backward_count + 1L }, true)
  } else {
    ({ last_ts: now, backward_count: self.backward_count }, false)
  }
}

///|
/// 获取回退次数
pub fn ClockBackwardDetector::backward_count(self : ClockBackwardDetector) -> Int64 {
  self.backward_count
}
