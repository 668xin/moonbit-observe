///|
test "Span new is idle" {
  let s = Span::new("root")
  assert_true(!s.is_running())
  assert_true(s.elapsed_nanos() == 0L)
}

///|
test "Span start and stop" {
  let s = Span::new("root").start()
  assert_true(s.is_running())
  let s1 = s.stop()
  assert_true(!s1.is_running())
  assert_true(s1.elapsed_nanos() >= 0L)
}

///|
test "Span with children" {
  let parent = Span::new("parent").start()
  let child1 = Span::new("child1").start()
  let child1_stopped = child1.stop()
  let parent_with_child = parent.add_child(child1_stopped)
  let parent_stopped = parent_with_child.stop()
  assert_true(parent_stopped.elapsed_nanos() >= 0L)
  let children = parent_stopped.children()
  assert_true(children.length() == 1)
  assert_true(children[0].name() == "child1")
}

///|
test "Span double start is no-op" {
  let s = Span::new("root").start()
  let s1 = s.start()
  assert_true(s1.is_running())
}
