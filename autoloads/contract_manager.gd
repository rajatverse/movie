extends Node

signal available_contracts_changed
signal active_assignments_changed
signal contract_delivered(contract_title: String, payout: int, on_time: bool)

var available_contracts: Array[ContractData] = []
var active_assignments: Dictionary = {}  # ContractData -> { "staff": StaffData, "start_week": int, "deadline_week": int }

func _ready() -> void:
	GameClock.week_passed.connect(_on_week_passed)
	load_seed_contracts()

func load_seed_contracts() -> void:
	available_contracts.clear()
	var seed_paths: Array[String] = [
		"res://data/contracts/contract_indie_promo.tres",
		"res://data/contracts/contract_vfx_intro.tres",
		"res://data/contracts/contract_jingle_score.tres",
		"res://data/contracts/contract_corporate_explainer.tres",
		"res://data/contracts/contract_film_poster.tres",
		"res://data/contracts/test_contract.tres"
	]
	
	for path in seed_paths:
		if ResourceLoader.exists(path):
			var res: ContractData = load(path) as ContractData
			if res and res not in available_contracts:
				available_contracts.append(res)
				
	available_contracts_changed.emit()

func assign_to_contract(staff: StaffData, contract: ContractData) -> bool:
	var max_proj: int = OfficeManager.get_max_simultaneous_projects()
	if active_assignments.size() >= max_proj:
		print("Cannot assign contract '%s': Max simultaneous project capacity (%d/%d) reached! Upgrade Studio Tower." % [contract.contract_title, active_assignments.size(), max_proj])
		return false
		
	if contract in available_contracts:
		available_contracts.erase(contract)
	
	var start_w: int = GameClock.current_week
	var end_w: int = start_w + contract.deadline_weeks
	
	active_assignments[contract] = {
		"staff": staff,
		"start_week": start_w,
		"deadline_week": end_w
	}
	
	StaffManager.assign_to_contract(staff, contract)
	print("Assigned %s to '%s'. Start: W%d, Deadline: W%d" % [staff.staff_name, contract.contract_title, start_w, end_w])
	available_contracts_changed.emit()
	active_assignments_changed.emit()
	return true

func _on_week_passed(current_week: int) -> void:
	var contracts_to_deliver: Array[ContractData] = []
	
	for contract in active_assignments.keys():
		var assignment_data: Dictionary = active_assignments[contract]
		var deadline_week: int = assignment_data["deadline_week"]
		if current_week >= deadline_week:
			contracts_to_deliver.append(contract)
			
	for contract in contracts_to_deliver:
		var assignment_data: Dictionary = active_assignments[contract]
		var deadline_week: int = assignment_data["deadline_week"]
		var on_time: bool = current_week <= deadline_week
		deliver_contract(contract, on_time)

func deliver_contract(contract: ContractData, on_time: bool) -> void:
	var assigned_staff: StaffData = null
	if active_assignments.has(contract):
		assigned_staff = active_assignments[contract].get("staff", null)
	
	var payout_amount: int
	if on_time:
		payout_amount = contract.payout
		print("Delivered contract '%s' ON TIME! Payout: %d" % [contract.contract_title, payout_amount])
	else:
		payout_amount = int(contract.payout * 0.9)
		print("Delivered contract '%s' LATE! Reduced payout: %d" % [contract.contract_title, payout_amount])
	
	Economy.add_currency(payout_amount)
	
	if assigned_staff:
		StaffManager.apply_skill_growth(assigned_staff)
		assigned_staff.is_busy = false
		StaffManager.roster_changed.emit()
		
	active_assignments.erase(contract)
	active_assignments_changed.emit()
	contract_delivered.emit(contract.contract_title, payout_amount, on_time)
