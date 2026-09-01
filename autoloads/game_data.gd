extends Node

var studio_name: String = ""
var founder_name: String = ""
var city: String = ""

func serialize() -> Dictionary:
	return {
		"studio_name": studio_name,
		"founder_name": founder_name,
		"city": city
	}

func deserialize(data: Dictionary) -> void:
	studio_name = data.get("studio_name", "")
	founder_name = data.get("founder_name", "")
	city = data.get("city", "")
