extends Control

@onready var btn_continue: Button = $VBoxContainer/VBoxContainer/BtnContinue
@onready var btn_new_game: Button = $VBoxContainer/VBoxContainer/BtnNewGame
@onready var btn_settings: Button = $VBoxContainer/VBoxContainer/BtnSettings

func _ready() -> void:
	btn_continue.disabled = not SaveManager.has_save()
	
	btn_new_game.pressed.connect(_on_new_game)
	btn_continue.pressed.connect(_on_continue)
	btn_settings.pressed.connect(func(): print("Settings not implemented yet"))

func _on_new_game() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/studio_setup.tscn")

func _on_continue() -> void:
	if SaveManager.load_game():
		# TODO: change scene to the isometric studio world directly
		get_tree().change_scene_to_file("res://scenes/world/studio_world.tscn")
