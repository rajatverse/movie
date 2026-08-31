extends Control

signal staff_selected(staff: StaffData)

@onready var staff_list_container: VBoxContainer = $Panel/VBoxContainer/ScrollContainer/StaffList
@onready var cancel_btn: Button = $Panel/VBoxContainer/CancelBtn

var target_contract: ContractData

func _ready() -> void:
	cancel_btn.pressed.connect(_on_cancel_pressed)
	visible = false

func open_for_contract(contract: ContractData) -> void:
	target_contract = contract
	_render_staff_list()
	visible = true

func _on_cancel_pressed() -> void:
	visible = false

func _render_staff_list() -> void:
	for child in staff_list_container.get_children():
		child.queue_free()
		
	var available_staff: Array[StaffData] = StaffManager.get_available_staff()
		
	if available_staff.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "No available staff! (All hired staff are currently busy on contracts)."
		empty_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		staff_list_container.add_child(empty_lbl)
		return
		
	for staff in available_staff:
		var card: PanelContainer = PanelContainer.new()
		var margin: MarginContainer = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_bottom", 10)
		
		var hbox: HBoxContainer = HBoxContainer.new()
		
		var info_vbox: VBoxContainer = VBoxContainer.new()
		info_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
		
		var name_lbl: Label = Label.new()
		name_lbl.text = staff.staff_name
		name_lbl.add_theme_font_size_override("font_size", 16)
		
		var skill_lbl: Label = Label.new()
		skill_lbl.text = "%s (Skill: %.1f)" % [staff.primary_skill.capitalize(), staff.skill_level]
		skill_lbl.add_theme_font_size_override("font_size", 13)
		
		info_vbox.add_child(name_lbl)
		info_vbox.add_child(skill_lbl)
		
		var assign_btn: Button = Button.new()
		assign_btn.text = "Assign"
		assign_btn.custom_minimum_size = Vector2(90, 36)
		assign_btn.pressed.connect(func():
			staff_selected.emit(staff)
			visible = false
		)
		
		hbox.add_child(info_vbox)
		hbox.add_child(assign_btn)
		margin.add_child(hbox)
		card.add_child(margin)
		staff_list_container.add_child(card)
