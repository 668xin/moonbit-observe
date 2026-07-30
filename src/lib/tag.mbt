///|
/// Tag — 键值对标签
pub struct Tag {
  priv key : String
  priv value : String
}

///|
/// 创建标签
pub fn Tag::new(key : String, value : String) -> Tag {
  { key, value }
}

///|
/// 获取标签键
pub fn Tag::key(self : Tag) -> String {
  self.key
}

///|
/// 获取标签值
pub fn Tag::value(self : Tag) -> String {
  self.value
}

///|
/// Tags — 标签集合
pub struct Tags {
  priv tags : Array[Tag]
}

///|
/// 创建空标签集合
pub fn Tags::new() -> Tags {
  { tags: [] }
}

///|
/// 从数组创建标签集合
pub fn Tags::from_array(tags : Array[Tag]) -> Tags {
  { tags: tags, }
}

///|
/// 添加标签
pub fn Tags::add(self : Tags, tag : Tag) -> Tags {
  { tags: self.tags + [tag] }
}

///|
/// 添加键值对标签（便捷方法）
pub fn Tags::add_pair(self : Tags, key : String, value : String) -> Tags {
  self.add(Tag::new(key, value))
}

///|
/// 获取所有标签
pub fn Tags::list(self : Tags) -> Array[Tag] {
  self.tags
}

///|
/// 按键查找标签值
pub fn Tags::get(self : Tags, key : String) -> String? {
  let mut i = 0
  while i < self.tags.length() {
    if self.tags[i].key == key {
      return Some(self.tags[i].value)
    }
    i = i + 1
  }
  None
}

///|
/// 标签数量
pub fn Tags::count(self : Tags) -> Int {
  self.tags.length()
}
