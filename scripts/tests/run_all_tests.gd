extends Node

const GameClockTestScript = preload("res://scripts/tests/game_clock_test.gd")
const EconomyTestScript = preload("res://scripts/tests/economy_test.gd")
const StaffManagerTestScript = preload("res://scripts/tests/staff_manager_test.gd")
const ContractManagerTestScript = preload("res://scripts/tests/contract_manager_test.gd")
const OfficeManagerTestScript = preload("res://scripts/tests/office_manager_test.gd")
const MovieManagerTestScript = preload("res://scripts/tests/movie_manager_test.gd")
const ReleaseManagerTestScript = preload("res://scripts/tests/release_manager_test.gd")

func _ready() -> void:
	print("==============================================")
	print("  MOVIE TYCOON — AUTOMATED HEADLESS TEST SUITE")
	print("==============================================")
	print("Root children: ", get_tree().root.get_children())
	
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
	
	var office_test = OfficeManagerTestScript.new()
	add_child(office_test)
	var office_res = office_test.run_all()
	total_passes += office_res["passes"]
	total_fails += office_res["fails"]
	
	var movie_test = MovieManagerTestScript.new()
	add_child(movie_test)
	var movie_res = movie_test.run_all()
	total_passes += movie_res["passes"]
	total_fails += movie_res["fails"]
	
	var release_test = ReleaseManagerTestScript.new()
	add_child(release_test)
	var release_res = release_test.run_all()
	total_passes += release_res["passes"]
	total_fails += release_res["fails"]
	
	print("\n==============================================")
	print("  TOTAL RESULTS: %d PASSED, %d FAILED" % [total_passes, total_fails])
	print("==============================================")
	
	get_tree().quit(total_fails)

