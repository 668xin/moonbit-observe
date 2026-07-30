///|
test "SharedStopwatch basic operations" {
  let sw = SharedStopwatch::new()
  assert_true(!sw.is_running())
  let sw1 = sw.start()
  assert_true(sw1.is_running())
  let sw2 = sw1.stop()
  assert_true(!sw2.is_running())
  assert_true(sw2.elapsed_nanos() >= 0L)
}

///|
test "SharedStopwatch unique ids" {
  let sw1 = SharedStopwatch::new()
  let sw2 = SharedStopwatch::new()
  assert_true(sw1.id() != sw2.id())
}
