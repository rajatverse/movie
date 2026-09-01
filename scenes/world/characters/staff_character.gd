extends Node3D

enum State { IDLE, WALKING, WORKING, MEETING }
var current_state: State = State.IDLE

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	# Simple wandering or working logic can go here
	pass
