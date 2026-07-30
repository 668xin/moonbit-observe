///|
test "BaselineStore add and get" {
  let summary = StatisticalSummary::new().add(100L).add(200L).add(300L)
  let store = BaselineStore::new().add("test_func", summary)
  match store.get("test_func") {
    None => abort("record not found")
    Some(r) => {
      if !(r.name() == "test_func") { abort("name mismatch") }
      if !(r.mean_nanos() == 200L) { abort("mean should be 200") }
      if !(r.min_nanos() == 100L) { abort("min should be 100") }
      if !(r.max_nanos() == 300L) { abort("max should be 300") }
    }
  }
}

///|
test "BaselineStore to_json and from_json roundtrip" {
  let summary = StatisticalSummary::new().add(100L).add(200L)
  let store = BaselineStore::new().add("roundtrip_test", summary)
  let json = store.to_json()
  let parsed = BaselineStore::from_json(json)
  match parsed.get("roundtrip_test") {
    None => abort("record not found after roundtrip")
    Some(r) => {
      if !(r.name() == "roundtrip_test") { abort("name mismatch") }
      if !(r.mean_nanos() == 150L) { abort("mean should be 150, got " + r.mean_nanos().to_string()) }
    }
  }
}

///|
test "BaselineStore empty store has no records" {
  let store = BaselineStore::new()
  let all = store.all()
  if !(all.length() == 0) { abort("should be empty") }
}

///|
test "BaselineStore add multiple records" {
  let s1 = StatisticalSummary::new().add(100L).add(200L)
  let s2 = StatisticalSummary::new().add(300L).add(400L)
  let store = BaselineStore::new().add("func_a", s1).add("func_b", s2)
  let all = store.all()
  if !(all.length() == 2) { abort("should have 2 records") }
  match store.get("func_a") {
    None => abort("func_a not found")
    Some(r) => if !(r.name() == "func_a") { abort("name mismatch") }
  }
  match store.get("func_b") {
    None => abort("func_b not found")
    Some(r) => if !(r.name() == "func_b") { abort("name mismatch") }
  }
  match store.get("func_c") {
    None => () // expected
    Some(_) => abort("func_c should not exist")
  }
}

///|
test "BaselineStore from_json handles invalid input" {
  let store = BaselineStore::from_json("invalid json")
  let all = store.all()
  if !(all.length() == 0) { abort("should be empty for invalid input") }
}
