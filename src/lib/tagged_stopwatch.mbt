///|
/// TaggedStopwatch — 携带标签的计时器包装
///
/// 在 Stopwatch 基础上绑定额外的 key-value 标签，
/// 便于后续按标签聚合统计。
pub struct TaggedStopwatch {
  priv stopwatch : Stopwatch
  priv tags : Tags
}

///|
/// 创建带标签的计时器（默认系统时钟）
pub fn TaggedStopwatch::new(tags : Tags) -> TaggedStopwatch {
  { stopwatch: Stopwatch::new(), tags }
}

///|
/// 创建带标签的计时器（使用自定义时钟）
pub fn TaggedStopwatch::new_with_clock(tags : Tags, now_fn : () -> Int64) -> TaggedStopwatch {
  { stopwatch: Stopwatch::new_with_clock(now_fn), tags }
}

///|
/// 启动
pub fn TaggedStopwatch::start(self : TaggedStopwatch) -> TaggedStopwatch {
  { ..self, stopwatch: self.stopwatch.start() }
}

///|
/// 暂停
pub fn TaggedStopwatch::stop(self : TaggedStopwatch) -> TaggedStopwatch {
  { ..self, stopwatch: self.stopwatch.stop() }
}

///|
/// 恢复
pub fn TaggedStopwatch::resume(self : TaggedStopwatch) -> TaggedStopwatch {
  { ..self, stopwatch: self.stopwatch.resume() }
}

///|
/// 重置
pub fn TaggedStopwatch::reset(self : TaggedStopwatch) -> TaggedStopwatch {
  { ..self, stopwatch: self.stopwatch.reset() }
}

///|
/// 获取耗时（纳秒）
pub fn TaggedStopwatch::elapsed_nanos(self : TaggedStopwatch) -> Int64 {
  self.stopwatch.elapsed_nanos()
}

///|
/// 获取标签
pub fn TaggedStopwatch::tags(self : TaggedStopwatch) -> Tags {
  self.tags
}

///|
/// 获取底层 Stopwatch
pub fn TaggedStopwatch::stopwatch(self : TaggedStopwatch) -> Stopwatch {
  self.stopwatch
}

///|
/// 是否正在运行
pub fn TaggedStopwatch::is_running(self : TaggedStopwatch) -> Bool {
  self.stopwatch.is_running()
}
