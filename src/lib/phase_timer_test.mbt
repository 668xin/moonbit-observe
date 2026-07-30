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
