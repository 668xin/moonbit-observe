///|
/// JsonReporter — JSON 序列化报告
///
/// 将计时结果序列化为 JSON 字符串，可累积多个报告后统一输出。
pub struct JsonReporter {
  priv parts : Ref[Array[String]]
  priv pretty : Bool
}

///|
/// 创建新的 JsonReporter
pub fn JsonReporter::new() -> JsonReporter {
  { parts: { val: [] }, pretty: true }
}

///|
/// 创建带缩进选项的 JsonReporter
pub fn JsonReporter::with_options(pretty : Bool) -> JsonReporter {
  { parts: { val: [] }, pretty }
}

///|
/// 添加 Stopwatch 计时结果
pub fn JsonReporter::report_stopwatch(self : JsonReporter, name : String, elapsed_nanos : Int64, laps : Array[LapRecord]) -> Unit {
  let lap_json = laps_to_json(laps)
  let entry = "{\"type\":\"stopwatch\",\"name\":\"" + name + "\",\"elapsed_nanos\":" + elapsed_nanos.to_string() + ",\"laps\":" + lap_json + "}"
  self.parts.val = self.parts.val + [entry]
}

///|
/// 添加基准测试结果
pub fn JsonReporter::report_benchmark(self : JsonReporter, result : BenchmarkResult) -> Unit {
  let entry = "{\"type\":\"benchmark\",\"min_nanos\":" + result.min_nanos().to_string() + ",\"max_nanos\":" + result.max_nanos().to_string() + ",\"avg_nanos\":" + result.avg_nanos().to_string() + ",\"total_nanos\":" + result.total_nanos().to_string() + "}"
  self.parts.val = self.parts.val + [entry]
}

///|
/// 添加 Span 树
pub fn JsonReporter::report_span(self : JsonReporter, span : Span) -> Unit {
  let entry = span_to_json_str(span, 0)
  self.parts.val = self.parts.val + [entry]
}

fn span_to_json_str(s : Span, depth : Int) -> String {
  let indent = if depth > 0 { "\n" + String::make(depth * 2, ' ') } else { "" }
  let mut json = "{" + indent + "\"type\":\"span\","
  json = json + indent + "\"name\":\"" + s.name() + "\","
  json = json + indent + "\"elapsed_nanos\":" + s.elapsed_nanos().to_string() + ","
  json = json + indent + "\"running\":" + s.is_running().to_string()
  let children = s.children()
  if children.length() > 0 {
    json = json + "," + indent + "\"children\": ["
    let mut ci = 0
    while ci < children.length() {
      if ci > 0 { json = json + "," }
      json = json + span_to_json_str(children[ci], depth + 1)
      ci = ci + 1
    }
    json = json + indent + "]"
  }
  json = json + indent + "}"
  json
}

///|
/// 添加快照
pub fn JsonReporter::report_snapshot(self : JsonReporter, snapshot : Snapshot) -> Unit {
  self.parts.val = self.parts.val + [snapshot.to_json()]
}

///|
/// 刷新（JsonReporter 无操作）
pub fn JsonReporter::flush(_self : JsonReporter) -> Unit {
  // no-op
}

///|
/// 获取累积的 JSON 输出，格式化为 JSON 数组
pub fn JsonReporter::output(self : JsonReporter) -> String {
  let parts = self.parts.val
  if parts.length() == 0 {
    return "[]"
  }
  let mut json = "[\n"
  let mut i = 0
  while i < parts.length() {
    let part = parts[i]
    if self.pretty {
      json = json + "  " + part
    } else {
      json = json + part
    }
    if i < parts.length() - 1 {
      json = json + ","
    }
    json = json + "\n"
    i = i + 1
  }
  json = json + "]"
  json
}

///|
/// 重置累积的 JSON 数据
pub fn JsonReporter::reset(self : JsonReporter) -> Unit {
  self.parts.val = []
}

fn laps_to_json(laps : Array[LapRecord]) -> String {
  let mut json = "["
  let mut i = 0
  while i < laps.length() {
    let l = laps[i]
    json = json + "{\"label\":\"" + l.label() + "\",\"lap_nanos\":" + l.lap_nanos().to_string() + ",\"total_nanos\":" + l.total_nanos().to_string() + "}"
    if i < laps.length() - 1 {
      json = json + ","
    }
    i = i + 1
  }
  json = json + "]"
  json
}
