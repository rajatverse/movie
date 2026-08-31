extends Node

const GameClockTestScript = preload("res://scripts/tests/game_clock_test.gd")
const EconomyTestScript = preload("res://scripts/tests/economy_test.gd")
const StaffManagerTestScript = preload("res://scripts/tests/staff_manager_test.gd")
const ContractManagerTestScript = preload("res://scripts/tests/contract_manager_test.gd")

func _ready() -> void:
	print("==============================================")
	print("  MOVIE TYCOON — AUTOMATED HEADLESS TEST SUITE")
	print("==============================================")
	
	var total_passes: int = 0
	var total_fails: int = 0
	
	var clock_test = GameClockTestScript.new()
	add_child(clock_test)
	var clock_res = clock_test.run_all()
	total_passes += clock_res["passes"]
	total_fails += clock_res["fails"]
	
	var economy_test = EconomyTestScript.new()
	add_child(economy_test)
	var econ_res = economy_test.run_all()
	total_passes += econ_res["passes"]
	total_fails += econ_res["fails"]
	
	var staff_test = StaffManagerTestScript.new()
	add_child(staff_test)
	var staff_res = staff_test.run_all()
	total_passes += staff_res["passes"]
	total_fails += staff_res["fails"]
	
	var contract_test = ContractManagerTestScript.new()
	add_child(contract_test)
	var contract_res = contract_test.run_all()
	total_passes += contract_res["passes"]
	total_fails += contract_res["fails"]
	
	print("\n==============================================")
	print("  TOTAL RESULTS: %d PASSED, %d FAILED" % [total_passes, total_fails])
	print("==============================================")
	
	get_tree().quit(total_fails)
