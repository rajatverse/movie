extends Node

signal week_passed(week_number: int)

var current_week: int = 1

func advance_week() -> void:
	current_week += 1
	week_passed.emit(current_week)
