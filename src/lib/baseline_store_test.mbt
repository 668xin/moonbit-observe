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
