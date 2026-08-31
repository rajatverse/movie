extends Control

@onready var stats_label: Label = $VBoxContainer/HeaderPanel/Margin/HBox/StatsLabel
@onready var upgrade_button: Button = $VBoxContainer/HeaderPanel/Margin/HBox/UpgradeButton
@onready var tower_stack_container: VBoxContainer = $VBoxContainer/ScrollContainer/CenterContainer/TowerStackContainer

const FLOOR_COLORS: Array[Color] = [
	Color(0.2, 0.4, 0.6), # Base Ground
	Color(0.25, 0.5, 0.7), # Floor 2
	Color(0.3, 0.6, 0.8), # Floor 3
	Color(0.35, 0.65, 0.85), # Floor 4
	Color(0.4, 0.7, 0.9)  # Floor 5 (Penthouse)
]

func _ready() -> void:
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	OfficeManager.office_upgraded.connect(_on_office_upgraded)
	Economy.currency_changed.connect(func(_bal): _update_ui())
	StaffManager.roster_changed.connect(_update_ui)
	ContractManager.active_assignments_changed.connect(_update_ui)
	
	_update_ui()

func _on_upgrade_pressed() -> void:
	if OfficeManager.upgrade_office():
		_update_ui()

func _on_office_upgraded(_new_level: int) -> void:
	_update_ui()

func _update_ui() -> void:
	var office: OfficeData = OfficeManager.current_office
	if not office:
		return
		
	# Update Stats Label
	var current_staff: int = StaffManager.roster.size()
	var current_projects: int = ContractManager.active_assignments.size()
	
	stats_label.text = "Studio Tower: Floor %d\nStaff Cap: %d/%d | Active Projects: %d/%d" % [
		office.floor_level,
		current_staff, office.max_staff_capacity,
		current_projects, office.max_simultaneous_projects
	]
	
	# Update Upgrade Button
	if OfficeManager.current_tier_index >= OfficeManager.tiers.size() - 1:
		upgrade_button.text = "MAX TIER"
		upgrade_button.disabled = true
	else:
		upgrade_button.text = "Upgrade Tower (%d)" % office.upgrade_cost
		upgrade_button.disabled = not OfficeManager.can_upgrade()
		
	_render_tower_visuals(office.floor_level)

func _render_tower_visuals(current_floors: int) -> void:
	for child in tower_stack_container.get_children():
		child.queue_free()
		
	# Roof / Spire top element
	var roof: PanelContainer = PanelContainer.new()
	roof.custom_minimum_size = Vector2(160, 30)
	var roof_lbl: Label = Label.new()
	roof_lbl.text = "▲ ROOF TOP ▲"
	roof_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	roof_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	roof_lbl.add_theme_font_size_override("font_size", 12)
	roof.add_child(roof_lbl)
	tower_stack_container.add_child(roof)
	
	# Add floors from top down to ground
	for f in range(current_floors, 0, -1):
		var floor_panel: PanelContainer = PanelContainer.new()
		var width: float = 240.0 + (f * 10.0) # Slightly wider base towards ground
		floor_panel.custom_minimum_size = Vector2(width, 70)
		
		var color_idx: int = min(f - 1, FLOOR_COLORS.size() - 1)
		floor_panel.modulate = FLOOR_COLORS[color_idx]
		
		var margin: MarginContainer = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_bottom", 10)
		
		var vbox: VBoxContainer = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		
		var title: Label = Label.new()
		title.text = "══ FLOOR %d ══" % f
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.add_theme_font_size_override("font_size", 16)
		
		var subtitle: Label = Label.new()
		subtitle.text = "Studio Workspace Level %d" % f
		subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		subtitle.add_theme_font_size_override("font_size", 12)
		
		vbox.add_child(title)
		vbox.add_child(subtitle)
		margin.add_child(vbox)
		floor_panel.add_child(margin)
		
		tower_stack_container.add_child(floor_panel)
		
	# Ground Base
	var ground: PanelContainer = PanelContainer.new()
	ground.custom_minimum_size = Vector2(300, 45)
	ground.modulate = Color(0.2, 0.2, 0.25)
	var ground_lbl: Label = Label.new()
	ground_lbl.text = "██ GROUND BASE LOBBY ██"
	ground_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ground_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ground_lbl.add_theme_font_size_override("font_size", 13)
	ground.add_child(ground_lbl)
	tower_stack_container.add_child(ground)
