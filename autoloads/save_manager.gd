extends Node

const SAVE_PATH = "user://savegame.json"

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game() -> void:
	var data = {
		"game_data": get_node("/root/GameData").serialize(),
		"game_clock": {
			"current_week": get_node("/root/GameClock").current_week
		},
		"economy": {
			"currency": get_node("/root/Economy").currency
		}
		# We will add other managers as we verify them
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func load_game() -> bool:
	if not has_save():
		return false
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var err = json.parse(json_string)
		if err == OK:
			var data = json.data
			if data.has("game_data"):
				get_node("/root/GameData").deserialize(data["game_data"])
			if data.has("game_clock"):
				get_node("/root/GameClock").current_week = data["game_clock"].get("current_week", 1)
			if data.has("economy"):
				get_node("/root/Economy").currency = data["economy"].get("currency", 1000)
			return true
	return false
