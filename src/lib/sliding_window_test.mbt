///|
test "SlidingWindow empty" {
  let w = SlidingWindow::new(5)
  if !(w.size() == 0) { abort("empty window size should be 0") }
}

///|
test "SlidingWindow add values" {
  let w = SlidingWindow::new(3).add(10L).add(20L).add(30L)
  if !(w.size() == 3) { abort("size should be 3") }
  if !w.is_full() { abort("should be full") }
}

///|
test "SlidingWindow overwrites oldest" {
  let w = SlidingWindow::new(3).add(10L).add(20L).add(30L).add(40L)
  if !(w.size() == 3) { abort("size should be 3") }
}

///|
test "SlidingWindow median" {
  let w = SlidingWindow::new(5).add(50L).add(10L).add(30L).add(20L).add(40L)
  match w.median() {
    None => abort("median should exist")
    Some(m) => if !(m == 30L) { abort("median should be 30, got " + m.to_string()) }
  }
}
