class_name ReleaseManagerTest
extends Node

const ReleaseManagerScript = preload("res://autoloads/release_manager.gd")
const MovieDataScript = preload("res://resources/movie_data.gd")
const DistributorDataScript = preload("res://resources/distributor_data.gd")
const ReleaseDataScript = preload("res://resources/release_data.gd")

var passes: int = 0
var fails: int = 0

func run_all() -> Dictionary:
	passes = 0
	fails = 0
	print("\n=== RUNNING RELEASE MANAGER TESTS ===")
	test_setup_deducts_marketing()
	test_setup_refuses_unaffordable()
	test_weekly_advance_simulates_bo()
	print("ReleaseManager Tests Summary: %d PASSED, %d FAILED" % [passes, fails])
	return {"passes": passes, "fails": fails}

func assert_true(condition: bool, message: String) -> void:
	if condition:
		print("[PASS] %s" % message)
		passes += 1
	else:
		print("[FAIL] %s" % message)
		fails += 1

func _reset_manager() -> void:
	ReleaseManager.active_releases.clear()
	ReleaseManager.completed_releases.clear()

func _create_dummy_movie() -> Resource:
	var m = MovieDataScript.new()
	m.movie_title = "Test Movie"
	m.budget = 1000
	m.dna_mass_appeal = 80.0
	m.dna_critical_appeal = 70.0
	return m

func _create_dummy_distributor() -> Resource:
	var d = DistributorDataScript.new()
	d.display_name = "Test Dist"
	d.reach = 1.0
	d.screen_access = 100
	d.popularity = 50.0
	d.revenue_share = 0.5
	return d

func test_setup_deducts_marketing() -> void:
	_reset_manager()
	Economy.currency = 5000
	var before = Economy.currency
	
	var m = _create_dummy_movie()
	var d = _create_dummy_distributor()
	
	var release = ReleaseManager.setup_release(m, d, "Trailer")
	
	assert_true(release != null, "Setup succeeded for affordable marketing")
	assert_true(Economy.currency == before - 500, "Economy currency decreased by marketing cost (500)")
	assert_true(ReleaseManager.active_releases.size() == 1, "Release added to active_releases")

func test_setup_refuses_unaffordable() -> void:
	_reset_manager()
	Economy.currency = 100
	var m = _create_dummy_movie()
	var d = _create_dummy_distributor()
	
	var release = ReleaseManager.setup_release(m, d, "Television") # costs 2000
	
	assert_true(release == null, "Setup failed for unaffordable marketing")
	assert_true(Economy.currency == 100, "Economy currency unchanged")
	assert_true(ReleaseManager.active_releases.size() == 0, "No release added to active_releases")

func test_weekly_advance_simulates_bo() -> void:
	_reset_manager()
	Economy.currency = 10000
	
	var m = _create_dummy_movie()
	var d = _create_dummy_distributor()
	var release = ReleaseManager.setup_release(m, d, "None")
	
	var initial_bo = release.total_box_office
	assert_true(initial_bo == 0, "Initial BO is 0")
	
	# Simulate 1 week
	ReleaseManager._on_week_passed(1)
	
	assert_true(release.weeks_screened == 1, "Weeks screened advanced to 1")
	assert_true(release.total_box_office > 0, "Box office generated after week 1")
	assert_true(release.weekly_box_office.size() == 1, "Weekly BO array has 1 entry")
	
	# Simulate remaining weeks to hit MAX_THEATRICAL_WEEKS (8)
	for i in range(7):
		ReleaseManager._on_week_passed(i+2)
		
	assert_true(release.weeks_screened <= 8, "Weeks screened capped or release finished")
	assert_true(release.status == "completed", "Release status is completed")
	assert_true(ReleaseManager.active_releases.size() == 0, "Release removed from active")
	assert_true(ReleaseManager.completed_releases.size() == 1, "Release added to completed")
