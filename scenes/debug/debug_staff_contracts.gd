extends Control

@onready var hire_btn: Button = $VBoxContainer/HireBtn
@onready var assign_btn: Button = $VBoxContainer/AssignBtn
@onready var advance_grow_btn: Button = $VBoxContainer/AdvanceGrowBtn
@onready var deliver_ontime_btn: Button = $VBoxContainer/DeliverOnTimeBtn
@onready var deliver_late_btn: Button = $VBoxContainer/DeliverLateBtn
@onready var status_label: Label = $VBoxContainer/StatusLabel

var test_staffer: StaffData
var test_contract: ContractData

func _ready() -> void:
	# Preload sample test resources
	test_staffer = load("res://data/staff/test_staffer.tres") as StaffData
	test_contract = load("res://data/contracts/test_contract.tres") as ContractData
	
	# Connect signals
	hire_btn.pressed.connect(_on_hire_pressed)
	assign_btn.pressed.connect(_on_assign_pressed)
	advance_grow_btn.pressed.connect(_on_advance_grow_pressed)
	deliver_ontime_btn.pressed.connect(_on_deliver_ontime_pressed)
	deliver_late_btn.pressed.connect(_on_deliver_late_pressed)
	
	GameClock.week_passed.connect(_on_week_passed)
	Economy.currency_changed.connect(_on_currency_changed)
	
	_update_status()

func _update_status() -> void:
	var staff_info: String = "%s (Skill: %.2f)" % [test_staffer.staff_name, test_staffer.skill_level] if test_staffer else "None"
	status_label.text = "Week: %d | Balance: %d\nStaff: %s" % [GameClock.current_week, Economy.currency, staff_info]

func _on_week_passed(_week_num: int) -> void:
	_update_status()

func _on_currency_changed(_new_balance: int) -> void:
	_update_status()

func _on_hire_pressed() -> void:
	if test_staffer:
		StaffManager.hire_staff(test_staffer)
		_update_status()

func _on_assign_pressed() -> void:
	if test_staffer and test_contract:
		StaffManager.assign_to_contract(test_staffer, test_contract)

func _on_advance_grow_pressed() -> void:
	GameClock.advance_week()
	if test_staffer:
		StaffManager.apply_skill_growth(test_staffer)
		print("New skill level for %s: %.2f" % [test_staffer.staff_name, test_staffer.skill_level])
		_update_status()

func _on_deliver_ontime_pressed() -> void:
	if test_contract:
		ContractManager.deliver_contract(test_contract, true)
		print("Current Economy currency: %d" % Economy.currency)

func _on_deliver_late_pressed() -> void:
	if test_contract:
		ContractManager.deliver_contract(test_contract, false)
		print("Current Economy currency: %d" % Economy.currency)
