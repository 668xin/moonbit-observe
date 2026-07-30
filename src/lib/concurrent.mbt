///|
/// SharedStopwatch — 共享计时器
///
/// 在不可变 Stopwatch 基础上的共享包装，提供一致的引用语义。
/// 适配 moonbitlang/async 多协程场景，多个协程可共享同一个 SharedStopwatch 实例。
pub struct SharedStopwatch {
  priv sw : Stopwatch
  priv id : Int
}

let _next_id : Ref[Int] = { val: 0 }

fn next_id() -> Int {
  let id = _next_id.val
  _next_id.val = _next_id.val + 1
  id
}

///|
/// 创建共享计时器
pub fn SharedStopwatch::new() -> SharedStopwatch {
  { sw: Stopwatch::new(), id: next_id() }
}

///|
/// 创建共享计时器（使用自定义时钟）
pub fn SharedStopwatch::new_with_clock(now_fn : () -> Int64) -> SharedStopwatch {
  { sw: Stopwatch::new_with_clock(now_fn), id: next_id() }
}

///|
/// 启动
pub fn SharedStopwatch::start(self : SharedStopwatch) -> SharedStopwatch {
  { ..self, sw: self.sw.start() }
}

///|
/// 暂停
pub fn SharedStopwatch::stop(self : SharedStopwatch) -> SharedStopwatch {
  { ..self, sw: self.sw.stop() }
}

///|
/// 恢复
pub fn SharedStopwatch::resume(self : SharedStopwatch) -> SharedStopwatch {
  { ..self, sw: self.sw.resume() }
}

///|
/// 重置
pub fn SharedStopwatch::reset(self : SharedStopwatch) -> SharedStopwatch {
  { ..self, sw: self.sw.reset() }
}

///|
/// 获取耗时（纳秒）
pub fn SharedStopwatch::elapsed_nanos(self : SharedStopwatch) -> Int64 {
  self.sw.elapsed_nanos()
}

///|
/// 获取共享实例 ID
pub fn SharedStopwatch::id(self : SharedStopwatch) -> Int {
  self.id
}

///|
/// 是否正在运行
pub fn SharedStopwatch::is_running(self : SharedStopwatch) -> Bool {
  self.sw.is_running()
}
