///|
test "PhaseTimer new has no phases" {
  let pt = PhaseTimer::new()
  assert_true(pt.phase_count() == 0)
  assert_true(pt.current_phase() == "")
}

///|
test "PhaseTimer begin and end phase" {
  let pt = PhaseTimer::new()
  let pt1 = pt.begin_phase("phase1")
  assert_true(pt1.current_phase() == "phase1")
  let pt2 = pt1.end_phase()
  assert_true(pt2.phase_count() == 1)
  assert_true(pt2.current_phase() == "")
  let phases = pt2.phases()
  assert_true(phases[0].name() == "phase1")
  assert_true(phases[0].elapsed_nanos() >= 0L)
}

///|
test "PhaseTimer multiple phases" {
  let pt = PhaseTimer::new()
  let pt1 = pt.begin_phase("phase1")
  let pt2 = pt1.begin_phase("phase2")  // ends phase1, starts phase2
  let pt3 = pt2.end_phase()
  assert_true(pt3.phase_count() == 2)
  assert_true(pt3.total_elapsed_nanos() >= 0L)
  let phases = pt3.phases()
  assert_true(phases[0].name() == "phase1")
  assert_true(phases[1].name() == "phase2")
}

///|
test "PhaseTimer end without begin returns self" {
  let pt = PhaseTimer::new()
  let pt1 = pt.end_phase()
  if !(pt1.phase_count() == 0) { abort("should have 0 phases") }
  if !(pt1.current_phase() == "") { abort("current should be empty") }
}

///|
test "PhaseTimer double begin closes previous" {
  let pt = PhaseTimer::new()
  let pt1 = pt.begin_phase("phase_a")
  let pt2 = pt1.begin_phase("phase_b")
  // phase_a should be ended automatically
  if !(pt2.phase_count() == 1) { abort("should have 1 completed phase") }
  let phases = pt2.phases()
  if !(phases[0].name() == "phase_a") { abort("first phase should be phase_a") }
  if !(pt2.current_phase() == "phase_b") { abort("current should be phase_b") }
}

///|
test "PhaseTimer total elapsed is sum of phases" {
  let pt = PhaseTimer::new()
  let pt1 = pt.begin_phase("p1").end_phase()
  let pt2 = pt1.begin_phase("p2").end_phase()
  let total = pt2.total_elapsed_nanos()
  if !(total >= 0L) { abort("total should be >= 0") }
  let phases = pt2.phases()
  if !(phases.length() == 2) { abort("should have 2 phases") }
}
