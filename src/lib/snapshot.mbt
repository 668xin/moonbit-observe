///|
/// SnapshotEntry — 快照条目
pub enum SnapshotEntry {
  TimingEntry(String, Int64, Array[LapRecord])
  BenchmarkEntry(BenchmarkResult)
  SpanEntry(Span)
}

///|
/// Snapshot — 快照（时间点状态捕获）
///
/// 捕获某个时间点上各类计时和测量的完整状态。
/// 支持序列化为 JSON 字符串，可用于持久化或传输。
pub struct Snapshot {
  priv timestamp : Int64
  priv entries : Array[SnapshotEntry]
}

///|
/// 创建空快照
pub fn Snapshot::new(timestamp : Int64) -> Snapshot {
  { timestamp, entries: [] }
}

///|
/// 添加计时条目
pub fn Snapshot::add_timing(self : Snapshot, name : String, elapsed_nanos : Int64, laps : Array[LapRecord]) -> Snapshot {
  { ..self, entries: self.entries + [TimingEntry(name, elapsed_nanos, laps)] }
}

///|
/// 添加基准测试条目
pub fn Snapshot::add_benchmark(self : Snapshot, result : BenchmarkResult) -> Snapshot {
  { ..self, entries: self.entries + [BenchmarkEntry(result)] }
}

///|
/// 添加 Span 条目
pub fn Snapshot::add_span(self : Snapshot, span : Span) -> Snapshot {
  { ..self, entries: self.entries + [SpanEntry(span)] }
}

///|
/// 获取时间戳
pub fn Snapshot::timestamp(self : Snapshot) -> Int64 {
  self.timestamp
}

///|
/// 获取所有条目
pub fn Snapshot::entries(self : Snapshot) -> Array[SnapshotEntry] {
  self.entries
}

///|
/// 快照条目数量
pub fn Snapshot::entry_count(self : Snapshot) -> Int {
  self.entries.length()
}

///|
/// 序列化为 JSON 字符串
///
/// 输出结构：
/// {
///   "timestamp": 1234567890,
///   "entries": [
///     { "type": "timing", "name": "request", "elapsed_nanos": 1500, "laps": [...] },
///     { "type": "benchmark", "min_nanos": 10, "max_nanos": 100, "avg_nanos": 50, "total_nanos": 250 },
///     { "type": "span", "name": "root", "elapsed_nanos": 2000, "tags": [], "children": [...] }
///   ]
/// }
pub fn Snapshot::to_json(self : Snapshot) -> String {
  let ts = self.timestamp.to_string()
  let mut json = "{\n  \"timestamp\": " + ts + ",\n  \"entries\": [\n"
  let mut i = 0
  while i < self.entries.length() {
    json = json + "    " + entry_to_json(self.entries[i])
    if i < self.entries.length() - 1 {
      json = json + ","
    }
    json = json + "\n"
    i = i + 1
  }
  json = json + "  ]\n}"
  json
}

fn entry_to_json(entry : SnapshotEntry) -> String {
  match entry {
    TimingEntry(name, elapsed, laps) => {
      let mut lap_json = "["
      let mut i = 0
      while i < laps.length() {
        let l = laps[i]
        lap_json = lap_json + "{\"label\":\"" + l.label() + "\",\"lap_nanos\":" + l.lap_nanos().to_string() + ",\"total_nanos\":" + l.total_nanos().to_string() + "}"
        if i < laps.length() - 1 {
          lap_json = lap_json + ","
        }
        i = i + 1
      }
      lap_json = lap_json + "]"
      "{\"type\":\"timing\",\"name\":\"" + name + "\",\"elapsed_nanos\":" + elapsed.to_string() + ",\"laps\":" + lap_json + "}"
    }
    BenchmarkEntry(r) => {
      "{\"type\":\"benchmark\",\"min_nanos\":" + r.min_nanos().to_string() + ",\"max_nanos\":" + r.max_nanos().to_string() + ",\"avg_nanos\":" + r.avg_nanos().to_string() + ",\"total_nanos\":" + r.total_nanos().to_string() + "}"
    }
    SpanEntry(s) => {
      span_to_json(s, 0)
    }
  }
}

fn span_to_json(s : Span, depth : Int) -> String {
  let indent_str = String::make(depth * 2, ' ')
  let indent_child = String::make((depth + 1) * 2, ' ')
  let mut json = "{\n" + indent_child + "\"type\":\"span\",\n"
  json = json + indent_child + "\"name\":\"" + s.name() + "\",\n"
  json = json + indent_child + "\"elapsed_nanos\":" + s.elapsed_nanos().to_string() + ",\n"
  json = json + indent_child + "\"running\":" + s.is_running().to_string() + ",\n"
  // tags
  let tags = s.tags()
  let mut tag_json = "["
  let tag_list = tags.list()
  let mut ti = 0
  while ti < tag_list.length() {
    tag_json = tag_json + "{\"key\":\"" + tag_list[ti].key() + "\",\"value\":\"" + tag_list[ti].value() + "\"}"
    if ti < tag_list.length() - 1 { tag_json = tag_json + "," }
    ti = ti + 1
  }
  tag_json = tag_json + "]"
  json = json + indent_child + "\"tags\":" + tag_json + ",\n"
  // children
  let children = s.children()
  if children.length() > 0 {
    json = json + indent_child + "\"children\": [\n"
    let mut ci = 0
    while ci < children.length() {
      json = json + indent_child + "  " + span_to_json(children[ci], depth + 2)
      if ci < children.length() - 1 { json = json + "," }
      json = json + "\n"
      ci = ci + 1
    }
    json = json + indent_child + "]\n"
  } else {
    json = json + indent_child + "\"children\": []\n"
  }
  json = json + indent_str + "}"
  json
}

///|
/// 从 JSON 字符串反序列化为 Snapshot
/// 简易字符遍历解析器
pub fn Snapshot::from_json(json : String) -> Snapshot {
  let len = json.length()
  let mut ci = 0
  let mut ts = 0L
  let mut entries : Array[SnapshotEntry] = []
  let mut in_entries = false
  let mut depth = 0
  let mut entry_start = 0
  let mut in_entry = false

  while ci < len {
    let ch = json[ci]
    if ch == 123 { // '{'
      if depth == 0 {
        depth = 1
      } else if depth == 1 && !in_entry {
        // sub object - might be entry start
        if in_entries {
          in_entry = true
          entry_start = ci
        }
        depth = depth + 1
      } else {
        depth = depth + 1
      }
    } else if ch == 125 { // '}'
      depth = depth - 1
      if in_entry && depth == 1 {
        in_entry = false
        let entry_str = json.sub(start=entry_start, end=ci + 1).to_owned()
        let parsed = parse_single_entry(entry_str)
        match parsed {
          Some(e) => entries = entries + [e]
          None => ()
        }
      }
    } else if ch == 34 { // '"'
      ci = ci + 1
      let key_start = ci
      while ci < len && json[ci] != 34 { ci = ci + 1 }
      let key = json.sub(start=key_start, end=ci).to_owned()
      // Skip to value
      while ci < len && json[ci] != 58 { ci = ci + 1 } // ':'
      ci = ci + 1
      // Skip whitespace
      while ci < len && (json[ci] == 32 || json[ci] == 10 || json[ci] == 13 || json[ci] == 9) { ci = ci + 1 }

      if key == "timestamp" && depth == 1 && !in_entries {
        let num_start = ci
        while ci < len && json[ci] >= 48 && json[ci] <= 57 { ci = ci + 1 }
        ts = parse_int64_str(json.sub(start=num_start, end=ci).to_owned())
        ci = ci - 1
      } else if key == "entries" && depth == 1 {
        in_entries = true
        // skip '[' or whitespace
      } else if key == "type" && in_entry {
        // parse value string
        if json[ci] == 34 { // '"'
          ci = ci + 1
          let val_start = ci
          while ci < len && json[ci] != 34 { ci = ci + 1 }
          let _type_val = json.sub(start=val_start, end=ci).to_owned()
        }
      }
    }
    ci = ci + 1
  }
  { timestamp: ts, entries }
}

fn parse_single_entry(s : String) -> SnapshotEntry? {
  let len = s.length()
  let mut ci = 0
  let mut entry_type = ""
  let mut name = ""
  let mut elapsed = 0L
  let mut min_n = 0L
  let mut max_n = 0L
  let mut avg_n = 0L
  let mut total_n = 0L

  while ci < len {
    let ch = s[ci]
    if ch == 34 { // '"'
      ci = ci + 1
      let key_start = ci
      while ci < len && s[ci] != 34 { ci = ci + 1 }
      let key = s.sub(start=key_start, end=ci).to_owned()
      // Skip to value
      while ci < len && s[ci] != 58 { ci = ci + 1 }
      ci = ci + 1
      while ci < len && (s[ci] == 32 || s[ci] == 10 || s[ci] == 13 || s[ci] == 9) { ci = ci + 1 }

      if key == "type" && ci < len && s[ci] == 34 {
        ci = ci + 1
        let val_start = ci
        while ci < len && s[ci] != 34 { ci = ci + 1 }
        entry_type = s.sub(start=val_start, end=ci).to_owned()
      } else if key == "name" && ci < len && s[ci] == 34 {
        ci = ci + 1
        let val_start = ci
        while ci < len && s[ci] != 34 { ci = ci + 1 }
        name = s.sub(start=val_start, end=ci).to_owned()
      } else if key == "elapsed_nanos" || key == "min_nanos" || key == "max_nanos" || key == "avg_nanos" || key == "total_nanos" {
        let num_start = ci
        while ci < len && s[ci] >= 48 && s[ci] <= 57 { ci = ci + 1 }
        let num_val = parse_int64_str(s.sub(start=num_start, end=ci).to_owned())
        if key == "elapsed_nanos" { elapsed = num_val }
        else if key == "min_nanos" { min_n = num_val }
        else if key == "max_nanos" { max_n = num_val }
        else if key == "avg_nanos" { avg_n = num_val }
        else if key == "total_nanos" { total_n = num_val }
      } else if key == "label" && ci < len && s[ci] == 34 {
        ci = ci + 1
        let val_start = ci
        while ci < len && s[ci] != 34 { ci = ci + 1 }
        let _label = s.sub(start=val_start, end=ci).to_owned()
      } else if key == "lap_nanos" {
        let num_start = ci
        while ci < len && s[ci] >= 48 && s[ci] <= 57 { ci = ci + 1 }
        let _lap_val = parse_int64_str(s.sub(start=num_start, end=ci).to_owned())
      }
    }
    ci = ci + 1
  }

  if entry_type == "timing" {
    Some(TimingEntry(name, elapsed, []))
  } else if entry_type == "benchmark" {
    Some(BenchmarkEntry(BenchmarkResult::new(min_n, max_n, avg_n, total_n)))
  } else if entry_type == "span" {
    let span = Span::new(name)
    Some(SpanEntry(span))
  } else {
    None
  }
}


