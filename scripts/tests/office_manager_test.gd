class_name OfficeManagerTest
extends Node

var passes: int = 0
var fails: int = 0

func run_all() -> Dictionary:
	passes = 0
	fails = 0
	print("\n=== RUNNING OFFICE MANAGER TESTS ===")
	test_can_upgrade_gating()
	test_upgrade_office()
	test_capacity_refusal_and_upgrade_resolution()
	print("OfficeManager Tests Summary: %d PASSED, %d FAILED" % [passes, fails])
	return {"passes": passes, "fails": fails}

func assert_true(condition: bool, message: String) -> void:
	if condition:
		print("[PASS] %s" % message)
		passes += 1
	else:
		print("[FAIL] %s" % message)
		fails += 1

func test_can_upgrade_gating() -> void:
	# Reset tier to tier 0 (floor 1, upgrade cost 2000)
	OfficeManager.current_tier_index = 0
	OfficeManager.current_office = OfficeManager.tiers[0]
	
	# Force currency to 500 (below 2000 cost)
	Economy.currency = 500
	assert_true(not OfficeManager.can_upgrade(), "OfficeManager.can_upgrade() returns false when balance (500) < upgrade_cost (2000)")
	
	# Set currency to 3000 (above 2000 cost)
	Economy.currency = 3000
	assert_true(OfficeManager.can_upgrade(), "OfficeManager.can_upgrade() returns true when balance (3000) >= upgrade_cost (2000)")

func test_upgrade_office() -> void:
	OfficeManager.current_tier_index = 0
	OfficeManager.current_office = OfficeManager.tiers[0]
	Economy.currency = 3000
	
	var initial_floor: int = OfficeManager.current_office.floor_level
	var initial_staff_cap: int = OfficeManager.get_max_staff_capacity()
	var initial_proj_cap: int = OfficeManager.get_max_simultaneous_projects()
	
	var signal_data: Dictionary = {"emitted": false, "new_level": -1}
	var callback = func(lvl: int):
		signal_data["emitted"] = true
		signal_data["new_level"] = lvl
		
	OfficeManager.office_upgraded.connect(callback)
	var success: bool = OfficeManager.upgrade_office()
	
	assert_true(success, "OfficeManager.upgrade_office() returned true on valid upgrade")
	assert_true(signal_data["emitted"], "OfficeManager.office_upgraded signal emitted on upgrade")
	assert_true(signal_data["new_level"] == 2, "OfficeManager.office_upgraded signal payload matched new floor level 2")
	assert_true(OfficeManager.current_office.floor_level == initial_floor + 1, "OfficeManager.current_office.floor_level incremented to 2")
	assert_true(OfficeManager.get_max_staff_capacity() > initial_staff_cap, "OfficeManager max_staff_capacity increased from %d to %d" % [initial_staff_cap, OfficeManager.get_max_staff_capacity()])
	assert_true(OfficeManager.get_max_simultaneous_projects() > initial_proj_cap, "OfficeManager max_simultaneous_projects increased from %d to %d" % [initial_proj_cap, OfficeManager.get_max_simultaneous_projects()])
	
	OfficeManager.office_upgraded.disconnect(callback)

func test_capacity_refusal_and_upgrade_resolution() -> void:
	# Reset to Tier 1: floor 1 (staff cap: 3, project cap: 1)
	OfficeManager.current_tier_index = 0
	OfficeManager.current_office = OfficeManager.tiers[0]
	StaffManager.roster.clear()
	ContractManager.active_assignments.clear()
	
	# Fill staff roster to capacity (3)
	for i in range(3):
		var s: StaffData = StaffData.new()
		s.staff_name = "CapWorker_%d" % i
		s.skill_level = 10.0
		s.salary = 100
		var hired: bool = StaffManager.hire_staff(s)
		assert_true(hired, "Hired worker %d within capacity" % i)
		
	assert_true(StaffManager.roster.size() == 3, "Roster size reached max capacity of 3")
	
	# Attempt to hire 4th worker at capacity
	var overflow_worker: StaffData = StaffData.new()
	overflow_worker.staff_name = "OverflowWorker"
	var overflow_hired: bool = StaffManager.hire_staff(overflow_worker)
	assert_true(not overflow_hired, "StaffManager.hire_staff() refused when roster is at max staff capacity (3/3)")
	assert_true(StaffManager.roster.size() == 3, "Roster size remained capped at 3")
	
	# Fill contract project assignments to capacity (1)
	var c1: ContractData = ContractData.new()
	c1.contract_title = "Cap Contract 1"
	c1.deadline_weeks = 4
	c1.payout = 1000
	ContractManager.available_contracts.append(c1)
	
	var c2: ContractData = ContractData.new()
	c2.contract_title = "Cap Contract 2"
	c2.deadline_weeks = 4
	c2.payout = 1000
	ContractManager.available_contracts.append(c2)
	
	var assigned_c1: bool = ContractManager.assign_to_contract(StaffManager.roster[0], c1)
	assert_true(assigned_c1, "Assigned project 1 within capacity")
	assert_true(ContractManager.active_assignments.size() == 1, "Active assignments reached max project capacity of 1")
	
	# Attempt to assign 2nd contract at capacity
	var assigned_c2_refused: bool = ContractManager.assign_to_contract(StaffManager.roster[1], c2)
	assert_true(not assigned_c2_refused, "ContractManager.assign_to_contract() refused when at max project capacity (1/1)")
	assert_true(ContractManager.active_assignments.size() == 1, "Active assignments size remained capped at 1")
	
	# Now upgrade office to Tier 2 (floor 2: staff cap 6, project cap 2)
	Economy.currency = 10000
	var upgraded: bool = OfficeManager.upgrade_office()
	assert_true(upgraded, "Upgraded office to Tier 2 (cap: 6 staff, 2 projects)")
	
	# Retry hiring overflow worker -> should succeed now
	var retry_hire: bool = StaffManager.hire_staff(overflow_worker)
	assert_true(retry_hire, "StaffManager.hire_staff() succeeded after office upgrade raised staff capacity cap")
	assert_true(StaffManager.roster.size() == 4, "Roster size expanded to 4")
	
	# Retry assigning 2nd contract -> should succeed now
	var retry_assign: bool = ContractManager.assign_to_contract(StaffManager.roster[1], c2)
	assert_true(retry_assign, "ContractManager.assign_to_contract() succeeded after office upgrade raised project capacity cap")
	assert_true(ContractManager.active_assignments.size() == 2, "Active assignments size expanded to 2")
