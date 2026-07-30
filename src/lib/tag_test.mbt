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
