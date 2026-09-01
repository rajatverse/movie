extends SceneTree
func _init():
	var files = ['game_data.gd', 'game_clock.gd', 'economy.gd', 'staff_manager.gd', 'contract_manager.gd', 'office_manager.gd', 'movie_manager.gd', 'save_manager.gd']
	for f in files:
		var res = load("res://autoloads/" + f)
		print(f + ": ", res)
	quit()
