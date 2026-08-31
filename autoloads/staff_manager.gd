extends Node

signal roster_changed

var roster: Array[StaffData] = []

const FIRST_NAMES: Array[String] = ["Morgan", "Sam", "Jordan", "Taylor", "Avery", "Riley", "Casey", "Dakota", "Quinn", "Reese"]
const LAST_NAMES: Array[String] = ["Vance", "River", "Blake", "Reed", "Brooks", "Skyler", "Harper", "Sterling", "Ellis"]
const SKILL_TYPES: Array[String] = ["editing", "graphics", "music", "writing"]
const TRAIT_NAMES: Array[String] = ["Fast Worker", "Perfectionist", "Creative", "Meticulous", "Passionate"]

func hire_staff(data: StaffData) -> bool:
	var max_cap: int = OfficeManager.get_max_staff_capacity()
	if roster.size() >= max_cap:
		print("Cannot hire %s: Office staff capacity (%d/%d) reached! Upgrade Studio Tower." % [data.staff_name, roster.size(), max_cap])
		return false
		
	if data not in roster:
		roster.append(data)
		print("Hired staff member: %s (Skill: %.1f, Salary: %d)" % [data.staff_name, data.skill_level, data.salary])
		roster_changed.emit()
		return true
	return false

func generate_random_staff() -> StaffData:
	var max_cap: int = OfficeManager.get_max_staff_capacity()
	if roster.size() >= max_cap:
		print("Cannot generate staff: Office staff capacity (%d/%d) reached!" % [roster.size(), max_cap])
		return null
		
	var first_name: String = FIRST_NAMES[randi() % FIRST_NAMES.size()]
	var last_name: String = LAST_NAMES[randi() % LAST_NAMES.size()]
	var staff_name: String = "%s %s" % [first_name, last_name]
	
	var primary_skill: String = SKILL_TYPES[randi() % SKILL_TYPES.size()]
	var skill_level: float = round(randf_range(10.0, 25.0) * 10.0) / 10.0
	var salary: int = int(skill_level * 30.0) + (randi() % 50)
	var trait_name: String = TRAIT_NAMES[randi() % TRAIT_NAMES.size()]
	
	var new_staff: StaffData = StaffData.new()
	new_staff.staff_name = staff_name
	new_staff.primary_skill = primary_skill
	new_staff.skill_level = skill_level
	new_staff.salary = salary
	new_staff.trait_name = trait_name
	
	if hire_staff(new_staff):
		return new_staff
	return null

func get_available_staff() -> Array[StaffData]:
	var available: Array[StaffData] = []
	for staff in roster:
		if not staff.is_busy:
			available.append(staff)
	return available

func assign_to_contract(staff: StaffData, contract: ContractData) -> void:
	staff.is_busy = true
	print("Assigned %s to contract '%s'" % [staff.staff_name, contract.contract_title])
	roster_changed.emit()

func apply_skill_growth(staff: StaffData) -> void:
	var trait_modifier: float = 1.0
	staff.skill_level += 2.0 * (1.0 - staff.skill_level / 100.0) * trait_modifier
	print("%s skill grown. New skill level: %.2f" % [staff.staff_name, staff.skill_level])
	roster_changed.emit()
