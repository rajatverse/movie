class_name ContractManagerTest
extends Node

var passes: int = 0
var fails: int = 0

func run_all() -> Dictionary:
	passes = 0
	fails = 0
	print("\n=== RUNNING CONTRACT MANAGER TESTS ===")
	StaffManager.roster.clear()
	ContractManager.active_assignments.clear()
	if OfficeManager and OfficeManager.tiers.size() > 0:
		OfficeManager.current_tier_index = 0
		OfficeManager.current_office = OfficeManager.tiers[0]
		
	test_on_time_payout()
	test_late_payout()
	test_active_assignments_clearing()
	print("ContractManager Tests Summary: %d PASSED, %d FAILED" % [passes, fails])
	return {"passes": passes, "fails": fails}

func assert_true(condition: bool, message: String) -> void:
	if condition:
		print("[PASS] %s" % message)
		passes += 1
	else:
		print("[FAIL] %s" % message)
		fails += 1

func test_on_time_payout() -> void:
	StaffManager.roster.clear()
	ContractManager.active_assignments.clear()
	
	var staff: StaffData = StaffData.new()
	staff.staff_name = "OnTime Worker"
	StaffManager.hire_staff(staff)
	
	var contract: ContractData = ContractData.new()
	contract.contract_title = "OnTime Test Contract"
	contract.payout = 2000
	contract.deadline_weeks = 2
	
	ContractManager.assign_to_contract(staff, contract)
	var initial_balance: int = Economy.currency
	
	ContractManager.deliver_contract(contract, true)
	
	assert_true(Economy.currency == initial_balance + 2000, "On-time contract delivery paid full payout 2000 (balance: %d -> %d)" % [initial_balance, initial_balance + 2000])

func test_late_payout() -> void:
	StaffManager.roster.clear()
	ContractManager.active_assignments.clear()
	
	var staff: StaffData = StaffData.new()
	staff.staff_name = "Late Worker"
	StaffManager.hire_staff(staff)
	
	var contract: ContractData = ContractData.new()
	contract.contract_title = "Late Test Contract"
	contract.payout = 2000
	contract.deadline_weeks = 1
	
	ContractManager.assign_to_contract(staff, contract)
	var initial_balance: int = Economy.currency
	var expected_payout: int = int(2000 * 0.9) # 1800
	
	ContractManager.deliver_contract(contract, false)
	
	assert_true(Economy.currency == initial_balance + expected_payout, "Late contract delivery paid 0.9x penalty payout 1800 (balance: %d -> %d)" % [initial_balance, initial_balance + expected_payout])

func test_active_assignments_clearing() -> void:
	StaffManager.roster.clear()
	ContractManager.active_assignments.clear()
	
	var staff: StaffData = StaffData.new()
	staff.staff_name = "Clear Worker"
	StaffManager.hire_staff(staff)
	
	var contract: ContractData = ContractData.new()
	contract.contract_title = "Clearing Test Contract"
	contract.payout = 1500
	contract.deadline_weeks = 2
	
	ContractManager.assign_to_contract(staff, contract)
	assert_true(contract in ContractManager.active_assignments, "Assigned contract is present in ContractManager.active_assignments")
	
	ContractManager.deliver_contract(contract, true)
	assert_true(contract not in ContractManager.active_assignments, "Delivered contract was cleared from ContractManager.active_assignments")
