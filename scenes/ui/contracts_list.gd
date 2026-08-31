extends Control

@onready var available_container: VBoxContainer = $VBoxContainer/ScrollContainer/MainVBox/AvailableSection/AvailableCards
@onready var active_container: VBoxContainer = $VBoxContainer/ScrollContainer/MainVBox/ActiveSection/ActiveCards
@onready var staff_picker: Control = $StaffPickerDialog

var selected_contract_for_assignment: ContractData = null

func _ready() -> void:
	ContractManager.available_contracts_changed.connect(_render_ui)
	ContractManager.active_assignments_changed.connect(_render_ui)
	GameClock.week_passed.connect(_on_week_passed)
	staff_picker.staff_selected.connect(_on_staff_selected_for_assignment)
	
	_render_ui()

func _on_week_passed(_week_num: int) -> void:
	_render_ui()

func _render_ui() -> void:
	_render_available_contracts()
	_render_active_contracts()

func _render_available_contracts() -> void:
	for child in available_container.get_children():
		child.queue_free()
		
	if ContractManager.available_contracts.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "No available contracts at the moment."
		empty_lbl.add_theme_font_size_override("font_size", 14)
		available_container.add_child(empty_lbl)
		return

	for contract in ContractManager.available_contracts:
		var card: PanelContainer = PanelContainer.new()
		var margin: MarginContainer = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_top", 12)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_bottom", 12)
		
		var hbox: HBoxContainer = HBoxContainer.new()
		
		var vbox: VBoxContainer = VBoxContainer.new()
		vbox.size_flags_horizontal = SIZE_EXPAND_FILL
		vbox.add_theme_constant_override("separation", 4)
		
		var title_lbl: Label = Label.new()
		title_lbl.text = contract.contract_title
		title_lbl.add_theme_font_size_override("font_size", 17)
		
		var details_lbl: Label = Label.new()
		details_lbl.text = "Task: %s | Payout: %d | Deadline: %d wks" % [contract.task_type.capitalize(), contract.payout, contract.deadline_weeks]
		details_lbl.add_theme_font_size_override("font_size", 14)
		
		vbox.add_child(title_lbl)
		vbox.add_child(details_lbl)
		
		var assign_btn: Button = Button.new()
		assign_btn.text = "Assign Staff"
		assign_btn.custom_minimum_size = Vector2(120, 40)
		assign_btn.pressed.connect(func():
			selected_contract_for_assignment = contract
			staff_picker.open_for_contract(contract)
		)
		
		hbox.add_child(vbox)
		hbox.add_child(assign_btn)
		margin.add_child(hbox)
		card.add_child(margin)
		available_container.add_child(card)

func _render_active_contracts() -> void:
	for child in active_container.get_children():
		child.queue_free()
		
	if ContractManager.active_assignments.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "No active contract assignments."
		empty_lbl.add_theme_font_size_override("font_size", 14)
		active_container.add_child(empty_lbl)
		return

	for contract in ContractManager.active_assignments.keys():
		var assignment_data: Dictionary = ContractManager.active_assignments[contract]
		var staff: StaffData = assignment_data.get("staff", null)
		var deadline_week: int = assignment_data.get("deadline_week", 0)
		var weeks_remaining: int = max(0, deadline_week - GameClock.current_week)
		
		var card: PanelContainer = PanelContainer.new()
		var margin: MarginContainer = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_top", 12)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_bottom", 12)
		
		var vbox: VBoxContainer = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 4)
		
		var title_lbl: Label = Label.new()
		title_lbl.text = "%s (Active)" % contract.contract_title
		title_lbl.add_theme_font_size_override("font_size", 17)
		
		var staff_name_str: String = staff.staff_name if staff else "Unassigned"
		var info_lbl: Label = Label.new()
		info_lbl.text = "Assigned: %s | Payout: %d" % [staff_name_str, contract.payout]
		info_lbl.add_theme_font_size_override("font_size", 14)
		
		var countdown_lbl: Label = Label.new()
		countdown_lbl.text = "Weeks Remaining: %d (Deadline: W%d)" % [weeks_remaining, deadline_week]
		countdown_lbl.add_theme_font_size_override("font_size", 14)
		
		vbox.add_child(title_lbl)
		vbox.add_child(info_lbl)
		vbox.add_child(countdown_lbl)
		
		margin.add_child(vbox)
		card.add_child(margin)
		active_container.add_child(card)

func _on_staff_selected_for_assignment(staff: StaffData) -> void:
	if selected_contract_for_assignment and staff:
		ContractManager.assign_to_contract(staff, selected_contract_for_assignment)
		selected_contract_for_assignment = null
