extends Node3D

@onready var interaction_layer = $InteractionLayer

func _ready() -> void:
	# Initialize HUD based on data
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Simple raycast logic can go here or in InteractionLayer
		pass
