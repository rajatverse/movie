class_name StaffManagerTest
extends Node

var passes: int = 0
var fails: int = 0

func run_all() -> Dictionary:
	passes = 0
	fails = 0
	print("\n=== RUNNING STAFF MANAGER TESTS ===")
	test_hire_staff()
	test_skill_growth_diminishing_returns()
	test_staff_locking_fix()
	print("StaffManager Tests Summary: %d PASSED, %d FAILED" % [passes, fails])
	return {"passes": passes, "fails": fails}

func assert_true(condition: bool, message: String) -> void:
	if condition:
		print("[PASS] %s" % message)
		passes += 1
	else:
		print("[FAIL] %s" % message)
		fails += 1

func test_hire_staff() -> void:
	var initial_size: int = StaffManager.roster.size()
	var test_staff: StaffData = StaffData.new()
	test_staff.staff_name = "Test Worker"
	test_staff.primary_skill = "editing"
	test_staff.skill_level = 10.0
	test_staff.salary = 300
	
	StaffManager.hire_staff(test_staff)
	assert_true(StaffManager.roster.size() == initial_size + 1, "StaffManager.hire_staff added new staff member to roster")
	assert_true(test_staff in StaffManager.roster, "Staff member 'Test Worker' is present in StaffManager.roster")

func test_skill_growth_diminishing_returns() -> void:
	var staff: StaffData = StaffData.new()
	staff.staff_name = "Trainee"
	staff.skill_level = 10.0
	
	StaffManager.apply_skill_growth(staff)
	# Formula: 10.0 + 2.0 * (1.0 - 10.0/100.0) = 10.0 + 2.0 * 0.90 = 11.80
	var expected_level_low: float = 11.80
	assert_true(abs(staff.skill_level - expected_level_low) < 0.001, "Low skill level (10.0) grew to expected diminishing-returns value (11.80)")
	
	var senior_staff: StaffData = StaffData.new()
	senior_staff.staff_name = "Veteran"
	senior_staff.skill_level = 90.0
	
	StaffManager.apply_skill_growth(senior_staff)
	# Formula: 90.0 + 2.0 * (1.0 - 90.0/100.0) = 90.0 + 2.0 * 0.10 = 90.20
	var expected_level_high: float = 90.20
	assert_true(abs(senior_staff.skill_level - expected_level_high) < 0.001, "High skill level (90.0) grew to expected diminishing-returns value (90.20)")

func test_staff_locking_fix() -> void:
	var staff1: StaffData = StaffData.new()
	staff1.staff_name = "Alice Lock"
	staff1.primary_skill = "editing"
	staff1.is_busy = false
	StaffManager.hire_staff(staff1)
	
	var staff2: StaffData = StaffData.new()
	staff2.staff_name = "Bob Free"
	staff2.primary_skill = "graphics"
	staff2.is_busy = false
	StaffManager.hire_staff(staff2)
	
	assert_true(staff1 in StaffManager.get_available_staff(), "Freshly hired staff1 'Alice Lock' is in get_available_staff()")
	assert_true(staff2 in StaffManager.get_available_staff(), "Freshly hired staff2 'Bob Free' is in get_available_staff()")
	
	var dummy_contract: ContractData = ContractData.new()
	dummy_contract.contract_title = "Test VFX Lock Contract"
	dummy_contract.payout = 1000
	dummy_contract.deadline_weeks = 2
	
	ContractManager.assign_to_contract(staff1, dummy_contract)
	
	assert_true(staff1.is_busy == true, "Assigned staff1 'Alice Lock' is_busy is now true")
	assert_true(staff1 not in StaffManager.get_available_staff(), "Busy staff1 'Alice Lock' does NOT appear in get_available_staff()")
	assert_true(staff2 in StaffManager.get_available_staff(), "Unassigned staff2 'Bob Free' remains in get_available_staff()")
	
	# Deliver contract and verify availability is restored
	ContractManager.deliver_contract(dummy_contract, true)
	
	assert_true(staff1.is_busy == false, "Delivered staff1 'Alice Lock' is_busy is now false")
	assert_true(staff1 in StaffManager.get_available_staff(), "Delivered staff1 'Alice Lock' appears in get_available_staff() again")
