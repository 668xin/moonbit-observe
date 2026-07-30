///|
/// SpanState — Span 状态
pub enum SpanState {
  Idle
  Running
  Stopped
}

///|
/// Span — 嵌套阶段计时
///
/// 父子层次结构，支撑简易调用链追踪。
/// 每个 Span 可包含多个子 Span，自动累计子树耗时。
pub struct Span {
  priv name : String
  priv state : SpanState
  priv start_ts : Int64
  priv elapsed : Int64
  priv tags : Tags
  priv children : Array[Span]
  priv now_fn : () -> Int64
}

///|
/// 创建根 Span
pub fn Span::new(name : String) -> Span {
  { name, state: Idle, start_ts: 0L, elapsed: 0L, tags: Tags::new(), children: [], now_fn: fn() { @env.now().reinterpret_as_int64() * 1_000_000L } }
}

///|
/// 创建带标签的 Span
pub fn Span::new_with_tags(name : String, tags : Tags) -> Span {
  { name, state: Idle, start_ts: 0L, elapsed: 0L, tags, children: [], now_fn: fn() { @env.now().reinterpret_as_int64() * 1_000_000L } }
}

///|
/// 创建带自定义时钟的 Span
pub fn Span::new_with_clock(name : String, now_fn : () -> Int64) -> Span {
  { name, state: Idle, start_ts: 0L, elapsed: 0L, tags: Tags::new(), children: [], now_fn }
}

///|
/// 启动 Span
pub fn Span::start(self : Span) -> Span {
  match self.state {
    Idle => { ..self, state: Running, start_ts: (self.now_fn)() }
    _ => self
  }
}

///|
/// 停止 Span
pub fn Span::stop(self : Span) -> Span {
  match self.state {
    Running => {
      let now = (self.now_fn)()
      let el = self.elapsed + (now - self.start_ts)
      { ..self, state: Stopped, elapsed: el }
    }
    _ => self
  }
}

///|
/// 添加子 Span
pub fn Span::add_child(self : Span, child : Span) -> Span {
  { ..self, children: self.children + [child] }
}

///|
/// 获取 Span 名称
pub fn Span::name(self : Span) -> String {
  self.name
}

///|
/// 获取耗时（纳秒）
pub fn Span::elapsed_nanos(self : Span) -> Int64 {
  match self.state {
    Running => {
      let now = (self.now_fn)()
      self.elapsed + (now - self.start_ts)
    }
    _ => self.elapsed
  }
}

///|
/// 获取子 Span 列表
pub fn Span::children(self : Span) -> Array[Span] {
  self.children
}

///|
/// 获取标签
pub fn Span::tags(self : Span) -> Tags {
  self.tags
}

///|
/// 获取总耗时（含子树累计）
pub fn Span::total_elapsed_nanos(self : Span) -> Int64 {
  let self_time = self.elapsed_nanos()
  let mut child_total = 0L
  let mut i = 0
  while i < self.children.length() {
    child_total = child_total + self.children[i].elapsed_nanos()
    i = i + 1
  }
  // 如果 self 尚未 stop，用当前累计值
  if self_time >= child_total { self_time } else { child_total }
}

///|
/// 是否正在运行
pub fn Span::is_running(self : Span) -> Bool {
  match self.state {
    Running => true
    _ => false
  }
}
