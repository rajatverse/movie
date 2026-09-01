extends CanvasLayer

@onready var lbl_currency: Label = $VBoxContainer/TopBar/MarginContainer/HBoxContainer/LblCurrency
@onready var lbl_reputation: Label = $VBoxContainer/TopBar/MarginContainer/HBoxContainer/LblReputation
@onready var lbl_time: Label = $VBoxContainer/TopBar/MarginContainer/HBoxContainer/LblTime

@onready var btn_studio: Button = $VBoxContainer/BottomNav/MarginContainer/HBoxContainer/BtnStudio
@onready var btn_movies: Button = $VBoxContainer/BottomNav/MarginContainer/HBoxContainer/BtnMovies
@onready var btn_staff: Button = $VBoxContainer/BottomNav/MarginContainer/HBoxContainer/BtnStaff
@onready var btn_news: Button = $VBoxContainer/BottomNav/MarginContainer/HBoxContainer/BtnNews
@onready var btn_finance: Button = $VBoxContainer/BottomNav/MarginContainer/HBoxContainer/BtnFinance

@onready var content_area: Control = $VBoxContainer/Control
var current_panel: Node = null

func _ready() -> void:
	Economy.currency_changed.connect(_update_hud)
	GameClock.week_passed.connect(func(_w): _update_hud())
	
	btn_studio.pressed.connect(_on_studio_pressed)
	btn_movies.pressed.connect(_on_movies_pressed)
	btn_staff.pressed.connect(_on_staff_pressed)
	
	_update_hud()

func _update_hud(_val = 0) -> void:
	lbl_currency.text = "₹%d" % Economy.currency
	lbl_reputation.text = "⭐ %d" % 10 # Placeholder for reputation
	lbl_time.text = "W%d" % GameClock.current_week

func _on_studio_pressed() -> void:
	if current_panel:
		current_panel.queue_free()
		current_panel = null

func _open_panel(scene_path: String) -> void:
	_on_studio_pressed() # Clear current
	var scene = load(scene_path)
	if scene:
		current_panel = scene.instantiate()
		content_area.add_child(current_panel)
		# Try to make it fill the space
		if current_panel is Control:
			current_panel.set_anchors_preset(Control.PRESET_FULL_RECT)

func _on_movies_pressed() -> void:
	_open_panel("res://scenes/ui/movie_wizard.tscn")

func _on_staff_pressed() -> void:
	_open_panel("res://scenes/ui/staff_roster.tscn")
