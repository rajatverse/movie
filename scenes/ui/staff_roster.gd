extends Control

@onready var hire_btn: Button = $VBoxContainer/Header/HireBtn
@onready var cards_container: VBoxContainer = $VBoxContainer/ScrollContainer/CardsContainer

func _ready() -> void:
	hire_btn.pressed.connect(_on_hire_pressed)
	StaffManager.roster_changed.connect(_render_roster)
	
	# If roster is empty, hire initial staffer from test resource if available
	if StaffManager.roster.is_empty():
		var test_staffer: StaffData = load("res://data/staff/test_staffer.tres") as StaffData
		if test_staffer:
			StaffManager.hire_staff(test_staffer)
	
	_render_roster()

func _on_hire_pressed() -> void:
	StaffManager.generate_random_staff()

func _render_roster() -> void:
	for child in cards_container.get_children():
		child.queue_free()
		
	if StaffManager.roster.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "No staff members hired yet."
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cards_container.add_child(empty_lbl)
		return

	for staff in StaffManager.roster:
		var card: PanelContainer = PanelContainer.new()
		var margin: MarginContainer = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_top", 12)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_bottom", 12)
		
		var vbox: VBoxContainer = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 6)
		
		var name_lbl: Label = Label.new()
		var trait_str: String = " [%s]" % staff.trait_name if staff.trait_name != "" else ""
		name_lbl.text = "%s%s" % [staff.staff_name, trait_str]
		name_lbl.add_theme_font_size_override("font_size", 18)
		
		var details_lbl: Label = Label.new()
		details_lbl.text = "Skill: %s (Level %.1f) | Salary: %d / wk" % [staff.primary_skill.capitalize(), staff.skill_level, staff.salary]
		details_lbl.add_theme_font_size_override("font_size", 14)
		
		vbox.add_child(name_lbl)
		vbox.add_child(details_lbl)
		margin.add_child(vbox)
		card.add_child(margin)
		cards_container.add_child(card)
