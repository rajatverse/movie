extends Node

signal office_upgraded(new_floor_level: int)

var tiers: Array[OfficeData] = []
var current_tier_index: int = 0
var current_office: OfficeData

func _ready() -> void:
	load_office_tiers()

func load_office_tiers() -> void:
	tiers.clear()
	var paths: Array[String] = [
		"res://data/office/tier_1.tres",
		"res://data/office/tier_2.tres",
		"res://data/office/tier_3.tres",
		"res://data/office/tier_4.tres",
		"res://data/office/tier_5.tres"
	]
	
	for p in paths:
		if ResourceLoader.exists(p):
			var res: OfficeData = load(p) as OfficeData
			if res:
				tiers.append(res)
				
	if tiers.size() > 0:
		current_tier_index = 0
		current_office = tiers[0]
	else:
		# Fallback if resources fail to load
		current_office = OfficeData.new()
		current_office.floor_level = 1
		current_office.max_staff_capacity = 3
		current_office.max_simultaneous_projects = 1
		current_office.upgrade_cost = 2000
		tiers.append(current_office)

func get_max_staff_capacity() -> int:
	return current_office.max_staff_capacity if current_office else 3

func get_max_simultaneous_projects() -> int:
	return current_office.max_simultaneous_projects if current_office else 1

func can_upgrade() -> bool:
	if not current_office:
		return false
	if current_tier_index >= tiers.size() - 1:
		return false # Max tier reached
	return Economy.currency >= current_office.upgrade_cost

func upgrade_office() -> bool:
	if not can_upgrade():
		print("Cannot upgrade office. Insufficient funds or already max level.")
		return false
		
	var next_tier: OfficeData = tiers[current_tier_index + 1]
	var cost: int = current_office.upgrade_cost
	
	if Economy.try_spend(cost, "Upgrade Studio Tower to Floor %d" % next_tier.floor_level):
		current_tier_index += 1
		current_office = next_tier
		print("Upgraded Studio Tower to Floor %d! Staff Cap: %d, Project Cap: %d" % [current_office.floor_level, current_office.max_staff_capacity, current_office.max_simultaneous_projects])
		office_upgraded.emit(current_office.floor_level)
		return true
		
	return false
