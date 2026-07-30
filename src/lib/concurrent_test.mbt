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

///|
test "SharedStopwatch resume after stop" {
  let sw = SharedStopwatch::new().start().stop().resume()
  if !sw.is_running() { abort("should be running after resume") }
}

///|
test "SharedStopwatch reset after stop" {
  let sw = SharedStopwatch::new().start().stop().reset()
  if sw.is_running() { abort("should be idle after reset") }
  if !(sw.elapsed_nanos() == 0L) { abort("elapsed should be 0") }
}

///|
test "SharedStopwatch double start no-op" {
  let sw = SharedStopwatch::new().start().start()
  if !sw.is_running() { abort("should still be running") }
}

///|
test "SharedStopwatch ids are unique" {
  let sw1 = SharedStopwatch::new()
  let sw2 = SharedStopwatch::new()
  let sw3 = SharedStopwatch::new()
  if !(sw1.id() != sw2.id()) { abort("id1 and id2 should differ") }
  if !(sw1.id() != sw3.id()) { abort("id1 and id3 should differ") }
  if !(sw2.id() != sw3.id()) { abort("id2 and id3 should differ") }
}
