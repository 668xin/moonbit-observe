///|
/// BaselineRecord — 单条基线记录
pub struct BaselineRecord {
  priv name : String
  priv mean_nanos : Int64
  priv min_nanos : Int64
  priv max_nanos : Int64
  priv stddev_nanos : Int64
  priv sample_count : Int64
  priv recorded_at : Int64
}

///|
pub fn BaselineRecord::name(self : BaselineRecord) -> String { self.name }
pub fn BaselineRecord::mean_nanos(self : BaselineRecord) -> Int64 { self.mean_nanos }
pub fn BaselineRecord::min_nanos(self : BaselineRecord) -> Int64 { self.min_nanos }
pub fn BaselineRecord::max_nanos(self : BaselineRecord) -> Int64 { self.max_nanos }
pub fn BaselineRecord::stddev_nanos(self : BaselineRecord) -> Int64 { self.stddev_nanos }
pub fn BaselineRecord::sample_count(self : BaselineRecord) -> Int64 { self.sample_count }

fn now_nanos() -> Int64 {
  @env.now().reinterpret_as_int64() * 1_000_000L
}

///|
/// BaselineStore — 基线持久化存储
///
/// 使用 JSON 格式持久化基线记录到字符串。
pub struct BaselineStore {
  priv records : Array[BaselineRecord]
}

///|
pub fn BaselineStore::new() -> BaselineStore {
  { records: [] }
}

///|
/// 添加基线记录
pub fn BaselineStore::add(self : BaselineStore, name : String, summary : StatisticalSummary) -> BaselineStore {
  match (summary.mean(), summary.min(), summary.max()) {
    (Some(mean), Some(min), Some(max)) => {
      let stddev = match summary.stddev() {
        None => 0L
        Some(v) => v
      }
      let rec = BaselineRecord::{ name, mean_nanos: mean, min_nanos: min, max_nanos: max, stddev_nanos: stddev, sample_count: summary.count(), recorded_at: now_nanos() }
      { records: self.records + [rec] }
    }
    _ => return self
  }
}

///|
/// 根据名称查找基线
pub fn BaselineStore::get(self : BaselineStore, name : String) -> BaselineRecord? {
  let mut i = 0
  while i < self.records.length() {
    if self.records[i].name == name { return Some(self.records[i]) }
    i = i + 1
  }
  None
}

///|
/// 获取所有基线记录
pub fn BaselineStore::all(self : BaselineStore) -> Array[BaselineRecord] {
  self.records
}

///|
/// 序列化为 JSON 字符串
pub fn BaselineStore::to_json(self : BaselineStore) -> String {
  let mut json = "{\n  \"records\": [\n"
  let mut i = 0
  while i < self.records.length() {
    let r = self.records[i]
    json = json + "    {\n"
    json = json + "      \"name\": \"" + r.name + "\",\n"
    json = json + "      \"mean_nanos\": " + r.mean_nanos.to_string() + ",\n"
    json = json + "      \"min_nanos\": " + r.min_nanos.to_string() + ",\n"
    json = json + "      \"max_nanos\": " + r.max_nanos.to_string() + ",\n"
    json = json + "      \"stddev_nanos\": " + r.stddev_nanos.to_string() + ",\n"
    json = json + "      \"sample_count\": " + r.sample_count.to_string() + ",\n"
    json = json + "      \"recorded_at\": " + r.recorded_at.to_string() + "\n"
    if i < self.records.length() - 1 {
      json = json + "    },\n"
    } else {
      json = json + "    }\n"
    }
    i = i + 1
  }
  json = json + "  ]\n}"
  json
}

///|
/// 从 JSON 字符串反序列化
pub fn BaselineStore::from_json(json : String) -> BaselineStore {
  // Simplified character-based parser
  let mut records : Array[BaselineRecord] = []
  let len = json.length()
  let mut ci = 0
  let mut current_name = ""
  let mut current_mean = 0L
  let mut current_min = 0L
  let mut current_max = 0L
  let mut current_stddev = 0L
  let mut current_samples = 0L
  let mut in_record_block = false
  while ci < len {
    // Skip whitespace
    let mut ti = ci
    while ti < len {
      let b = json[ti]
      if b == 10 || b == 13 || b == 32 || b == 9 { // \n, \r, space, tab
        ti = ti + 1
      } else {
        break
      }
    }
    ci = ti
    if ci >= len { break }
    let ch = json[ci]
    if ch == 123 { // '{'
      if !in_record_block {
        in_record_block = true
        current_name = ""
        current_mean = 0L
        current_min = 0L
        current_max = 0L
        current_stddev = 0L
        current_samples = 0L
      }
      ci = ci + 1
    } else if ch == 125 { // '}'
      if in_record_block && current_name != "" {
        records = records + [BaselineRecord::{ name: current_name, mean_nanos: current_mean, min_nanos: current_min, max_nanos: current_max, stddev_nanos: current_stddev, sample_count: current_samples, recorded_at: 0L }]
      }
      in_record_block = false
      current_name = ""
      ci = ci + 1
    } else if ch == 34 { // '"' - start of key
      ci = ci + 1
      let key_start = ci
      while ci < len && json[ci] != 34 { ci = ci + 1 }
      let key = json.sub(start=key_start, end=ci).to_owned()
      if ci < len { ci = ci + 1 } // skip closing "
      // Skip whitespace and ':'
      while ci < len && (json[ci] == 32 || json[ci] == 58) { ci = ci + 1 } // space or ':'
      // Parse value
      if ci < len {
        if json[ci] == 34 { // '"' - string value
          ci = ci + 1
          let val_start = ci
          while ci < len && json[ci] != 34 { ci = ci + 1 }
          let val = json.sub(start=val_start, end=ci).to_owned()
          if ci < len { ci = ci + 1 } // skip closing "
          if in_record_block && key == "name" {
            current_name = val
          }
        } else {
          // numeric value
          let num_start = ci
          while ci < len && ((json[ci] >= 48 && json[ci] <= 57) || json[ci] == 45) { // digit or '-'
            ci = ci + 1
          }
          let num_str = json.sub(start=num_start, end=ci).to_owned()
          let num_val = parse_int64_str(num_str)
          if in_record_block {
            if key == "mean_nanos" { current_mean = num_val }
            else if key == "min_nanos" { current_min = num_val }
            else if key == "max_nanos" { current_max = num_val }
            else if key == "stddev_nanos" { current_stddev = num_val }
            else if key == "sample_count" { current_samples = num_val }
          }
        }
      }
    } else {
      ci = ci + 1
    }
  }
  { records: records }
}

fn parse_int64_str(s : String) -> Int64 {
  let len = s.length()
  let mut result = 0L
  let mut negative = false
  let mut started = false
  let mut ci = 0
  while ci < len {
    let b = s[ci]
    if b == 45 { // '-'
      negative = true
    } else if b >= 48 && b <= 57 {
      result = result * 10L + (b - 48).to_int64()
      started = true
    }
    ci = ci + 1
  }
  if started {
    if negative { -result } else { result }
  } else {
    0L
  }
}

