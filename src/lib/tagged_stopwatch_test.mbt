///|
test "TaggedStopwatch new creates idle" {
  let tags = Tags::new().add_pair("env", "test")
  let tw = TaggedStopwatch::new(tags)
  assert_true(!tw.is_running())
  assert_true(tw.elapsed_nanos() == 0L)
  assert_true(tw.tags().count() == 1)
}

///|
test "TaggedStopwatch start and stop" {
  let tags = Tags::new().add_pair("service", "api")
  let tw = TaggedStopwatch::new(tags)
  let tw1 = tw.start()
  assert_true(tw1.is_running())
  let tw2 = tw1.stop()
  assert_true(!tw2.is_running())
  assert_true(tw2.elapsed_nanos() >= 0L)
}

///|
test "TaggedStopwatch resume after stop" {
  let tags = Tags::new().add_pair("env", "test")
  let tw = TaggedStopwatch::new(tags).start().stop().resume()
  if !tw.is_running() { abort("should be running after resume") }
}

///|
test "TaggedStopwatch reset clears state" {
  let tags = Tags::new().add_pair("env", "test")
  let tw = TaggedStopwatch::new(tags).start().stop().reset()
  if tw.is_running() { abort("should be idle after reset") }
  if !(tw.elapsed_nanos() == 0L) { abort("elapsed should be 0 after reset") }
}

///|
test "TaggedStopwatch double start no-op" {
  let tags = Tags::new()
  let tw = TaggedStopwatch::new(tags).start().start()
  if !tw.is_running() { abort("should still be running") }
}

///|
test "TaggedStopwatch double stop no-op" {
  let tags = Tags::new()
  let tw = TaggedStopwatch::new(tags).start().stop().stop()
  if tw.is_running() { abort("should still be stopped") }
}
