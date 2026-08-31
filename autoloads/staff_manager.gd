extends Node

var roster: Array[StaffData] = []

func hire_staff(data: StaffData) -> void:
	if data not in roster:
		roster.append(data)
		print("Hired staff member: %s (Skill: %.1f, Salary: %d)" % [data.staff_name, data.skill_level, data.salary])

func assign_to_contract(staff: StaffData, contract: ContractData) -> void:
	print("Assigned %s to contract '%s'" % [staff.staff_name, contract.contract_title])

func apply_skill_growth(staff: StaffData) -> void:
	var trait_modifier: float = 1.0
	staff.skill_level += 2.0 * (1.0 - staff.skill_level / 100.0) * trait_modifier
	print("%s skill grown. New skill level: %.2f" % [staff.staff_name, staff.skill_level])
