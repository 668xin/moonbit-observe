///|
/// SlidingWindow — 固定大小滑动窗口，存储最近 N 个数据点
pub struct SlidingWindow {
  priv buffer : Array[Int64]
  priv capacity : Int
  priv head : Int
  priv count : Int
}

///|
pub fn SlidingWindow::new(capacity : Int) -> SlidingWindow {
  { buffer: Array::make(capacity, 0L), capacity, head: 0, count: 0 }
}

///|
pub fn SlidingWindow::add(self : SlidingWindow, value : Int64) -> SlidingWindow {
  let buf = self.buffer
  buf[self.head] = value
  let new_head = (self.head + 1) % self.capacity
  let new_count = if self.count < self.capacity { self.count + 1 } else { self.capacity }
  { ..self, buffer: buf, head: new_head, count: new_count }
}

///|
pub fn SlidingWindow::values(self : SlidingWindow) -> Array[Int64] {
  let n = self.count
  let result = Array::make(n, 0L)
  let mut i = 0
  while i < n {
    let idx = if i < self.head { self.head - 1 - i } else { self.capacity + self.head - 1 - i }
    result[i] = self.buffer[idx.mod(self.capacity)]
    i = i + 1
  }
  result
}

///|
pub fn SlidingWindow::size(self : SlidingWindow) -> Int {
  self.count
}

///|
pub fn SlidingWindow::is_full(self : SlidingWindow) -> Bool {
  self.count >= self.capacity
}

///|
/// 获取窗口中位数估算（简化版，对值排序后取中间）
pub fn SlidingWindow::median(self : SlidingWindow) -> Int64? {
  if self.count == 0 { return None }
  let vals = self.values()
  // insertion sort (small arrays)
  let mut i = 0
  while i < vals.length() {
    let mut j = i
    while j > 0 && vals[j - 1] > vals[j] {
      let tmp = vals[j]
      vals[j] = vals[j - 1]
      vals[j - 1] = tmp
      j = j - 1
    }
    i = i + 1
  }
  let mid = vals.length() / 2
  Some(vals[mid])
}
