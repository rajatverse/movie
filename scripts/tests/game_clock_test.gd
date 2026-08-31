class_name GameClockTest
extends Node

var passes: int = 0
var fails: int = 0

func run_all() -> Dictionary:
	passes = 0
	fails = 0
	print("\n=== RUNNING GAME CLOCK TESTS ===")
	test_game_clock_advancement()
	test_game_clock_signal()
	print("GameClock Tests Summary: %d PASSED, %d FAILED" % [passes, fails])
	return {"passes": passes, "fails": fails}

func assert_true(condition: bool, message: String) -> void:
	if condition:
		print("[PASS] %s" % message)
		passes += 1
	else:
		print("[FAIL] %s" % message)
		fails += 1

func test_game_clock_advancement() -> void:
	var initial_week: int = GameClock.current_week
	GameClock.advance_week()
	assert_true(GameClock.current_week == initial_week + 1, "GameClock.advance_week() increments current_week from %d to %d" % [initial_week, initial_week + 1])

func test_game_clock_signal() -> void:
	var signal_data: Dictionary = {"emitted": false, "received_week": -1}
	var callback = func(w: int):
		signal_data["emitted"] = true
		signal_data["received_week"] = w
		
	GameClock.week_passed.connect(callback)
	var expected_next_week: int = GameClock.current_week + 1
	GameClock.advance_week()
	assert_true(signal_data["emitted"], "GameClock.week_passed signal emitted on advance_week()")
	assert_true(signal_data["received_week"] == expected_next_week, "GameClock.week_passed payload matched expected week %d" % expected_next_week)
	GameClock.week_passed.disconnect(callback)
