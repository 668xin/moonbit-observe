///|
fn assert_eq_str(actual : String, expected : String) -> Unit {
  if actual != expected {
    abort("assert_eq_str failed: expected \"" + expected + "\", got \"" + actual + "\"")
  }
}

///|
fn assert_eq_int(actual : Int, expected : Int) -> Unit {
  if actual != expected {
    abort("assert_eq_int failed: expected " + expected.to_string() + ", got " + actual.to_string())
  }
}

///|
test "Tag::new creates tag" {
  let tag = Tag::new("env", "test")
  assert_eq_str(tag.key(), "env")
  assert_eq_str(tag.value(), "test")
}

///|
test "Tags add and list" {
  let tags = Tags::new().add_pair("env", "test").add_pair("service", "api")
  let list = tags.list()
  if !(list.length() == 2) { abort("should have 2 tags") }
  if !(tags.count() == 2) { abort("count should be 2") }
}

///|
test "Tags get by key" {
  let tags = Tags::new().add_pair("env", "prod")
  let val = tags.get("env")
  match val {
    Some(v) => assert_eq_str(v, "prod")
    None => abort("tag not found")
  }
}

///|
test "Tags get missing key" {
  let tags = Tags::new()
  let val = tags.get("missing")
  match val {
    Some(_) => abort("should be None")
    None => () // expected
  }
}

///|
test "Tags::new creates empty tags" {
  let tags = Tags::new()
  if !(tags.count() == 0) { abort("count should be 0") }
}

///|
test "Tags::add duplicate key keeps duplicates" {
  let tags = Tags::new().add_pair("env", "test").add_pair("env", "prod")
  if !(tags.count() == 2) { abort("count should be 2 (duplicate keys allowed)") }
}

///|
test "Tag::key and value roundtrip" {
  let tag = Tag::new("key1", "value1")
  if !(tag.key() == "key1") { abort("key mismatch") }
  if !(tag.value() == "value1") { abort("value mismatch") }
}

///|
test "Tags::from_array preserves order" {
  let arr = [Tag::new("a", "1"), Tag::new("b", "2")]
  let tags = Tags::from_array(arr)
  let list = tags.list()
  if !(list.length() == 2) { abort("length should be 2") }
  if !(list[0].key() == "a") { abort("order not preserved") }
}
