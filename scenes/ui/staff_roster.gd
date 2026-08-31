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
		if staff.is_busy:
			card.modulate = Color(0.8, 0.8, 0.85, 1.0)  # Dim slightly to show busy status visually
			
		var margin: MarginContainer = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_top", 12)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_bottom", 12)
		
		var vbox: VBoxContainer = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 6)
		
		var header_hbox: HBoxContainer = HBoxContainer.new()
		
		var name_lbl: Label = Label.new()
		var trait_str: String = " [%s]" % staff.trait_name if staff.trait_name != "" else ""
		name_lbl.text = "%s%s" % [staff.staff_name, trait_str]
		name_lbl.add_theme_font_size_override("font_size", 18)
		name_lbl.size_flags_horizontal = SIZE_EXPAND_FILL
		
		var status_badge: Label = Label.new()
		if staff.is_busy:
			status_badge.text = "[ BUSY ]"
			status_badge.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
		else:
			status_badge.text = "[ Free ]"
			status_badge.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
		status_badge.add_theme_font_size_override("font_size", 14)
		
		header_hbox.add_child(name_lbl)
		header_hbox.add_child(status_badge)
		
		var details_lbl: Label = Label.new()
		details_lbl.text = "Skill: %s (Level %.1f) | Salary: %d / wk" % [staff.primary_skill.capitalize(), staff.skill_level, staff.salary]
		details_lbl.add_theme_font_size_override("font_size", 14)
		
		vbox.add_child(header_hbox)
		vbox.add_child(details_lbl)
		margin.add_child(vbox)
		card.add_child(margin)
		cards_container.add_child(card)
