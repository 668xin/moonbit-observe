///|
/// MockClock — 可手动推进的虚拟时钟，用于测试
pub struct MockClock {
  priv current : Int64
}

pub fn MockClock::new(initial : Int64) -> MockClock {
  { current: initial }
}

///|
pub fn MockClock::now(self : MockClock) -> Int64 {
  self.current
}

///|
/// 推进指定纳秒数
pub fn MockClock::advance(self : MockClock, nanos : Int64) -> MockClock {
  { current: self.current + nanos }
}

///|
/// 推进指定毫秒数（便捷方法）
pub fn MockClock::advance_millis(self : MockClock, millis : Int64) -> MockClock {
  self.advance(millis * 1_000_000L)
}

///|
/// 重置到指定值
pub fn MockClock::reset(_self : MockClock, ts : Int64) -> MockClock {
  { current: ts }
}
