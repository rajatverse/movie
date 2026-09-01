extends Control

@onready var label_intro: Label = $VBoxContainer/LblIntro
@onready var btn_next: Button = $VBoxContainer/BtnNext
@onready var title: Label = $VBoxContainer/Title

var state: int = 0

func _ready() -> void:
	btn_next.pressed.connect(_on_next_pressed)
	_update_ui()

func _update_ui() -> void:
	if state == 0:
		title.text = "DAY 1"
		label_intro.text = "You've started your own\nproduction house.\n\nThe office is small.\nThe budget is limited.\n\nBut every major studio\nstarted somewhere."
		btn_next.text = "NEXT"
	else:
		title.text = "WELCOME TO"
		label_intro.text = GameData.studio_name.to_upper()
		label_intro.add_theme_font_size_override("font_size", 48)
		btn_next.text = "ENTER WORLD"

func _on_next_pressed() -> void:
	if state == 0:
		state = 1
		_update_ui()
	else:
		get_tree().change_scene_to_file("res://scenes/world/studio_world.tscn")
