///|
/// Phase — 单个阶段记录
pub struct Phase {
  priv name : String
  priv elapsed_nanos : Int64
}

///|
pub fn Phase::name(self : Phase) -> String {
  self.name
}

///|
pub fn Phase::elapsed_nanos(self : Phase) -> Int64 {
  self.elapsed_nanos
}

///|
/// PhaseTimer — 连续命名阶段计时
///
/// 依次记录多个连续阶段的耗时，适用于流水线作业。
pub struct PhaseTimer {
  priv phases : Array[Phase]
  priv current_name : String
  priv phase_start : Int64
  priv now_fn : () -> Int64
}

///|
/// 创建阶段计时器
pub fn PhaseTimer::new() -> PhaseTimer {
  { phases: [], current_name: "", phase_start: 0L, now_fn: fn() { @env.now().reinterpret_as_int64() * 1_000_000L } }
}

///|
/// 创建带自定义时钟的阶段计时器
pub fn PhaseTimer::new_with_clock(now_fn : () -> Int64) -> PhaseTimer {
  { phases: [], current_name: "", phase_start: 0L, now_fn }
}

///|
/// 开始一个新的阶段
pub fn PhaseTimer::begin_phase(self : PhaseTimer, name : String) -> PhaseTimer {
  let now = (self.now_fn)()
  // 如果已有活跃阶段，先结束它
  if self.current_name != "" {
    let elapsed = now - self.phase_start
    let phase = Phase::{ name: self.current_name, elapsed_nanos: elapsed }
    { ..self, phases: self.phases + [phase], current_name: name, phase_start: now }
  } else {
    { ..self, current_name: name, phase_start: now }
  }
}

///|
/// 结束当前阶段并返回计时器
pub fn PhaseTimer::end_phase(self : PhaseTimer) -> PhaseTimer {
  if self.current_name != "" {
    let now = (self.now_fn)()
    let elapsed = now - self.phase_start
    let phase = Phase::{ name: self.current_name, elapsed_nanos: elapsed }
    { ..self, phases: self.phases + [phase], current_name: "", phase_start: 0L }
  } else {
    self
  }
}

///|
/// 获取所有已完成阶段
pub fn PhaseTimer::phases(self : PhaseTimer) -> Array[Phase] {
  self.phases
}

///|
/// 获取阶段数量
pub fn PhaseTimer::phase_count(self : PhaseTimer) -> Int {
  self.phases.length()
}

///|
/// 获取当前阶段名称（如果正在运行）
pub fn PhaseTimer::current_phase(self : PhaseTimer) -> String {
  self.current_name
}

///|
/// 获取总耗时（所有已完成阶段之和）
pub fn PhaseTimer::total_elapsed_nanos(self : PhaseTimer) -> Int64 {
  let mut total = 0L
  let mut i = 0
  while i < self.phases.length() {
    total = total + self.phases[i].elapsed_nanos
    i = i + 1
  }
  total
}
