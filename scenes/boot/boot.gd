extends Control

func _ready() -> void:
	# Add a small delay so boot isn't visually instantaneous (simulates loading)
	await get_tree().create_timer(0.5).timeout
	
	# Try to load game if save exists, just to populate GameData if needed for menu
	# (Actually, main menu should decide whether to load it or start new)
	
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
