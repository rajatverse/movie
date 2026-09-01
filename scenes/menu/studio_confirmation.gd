extends Control

@onready var lbl_studio_name: Label = $VBoxContainer/Panel/VBoxContainer/LblStudioName
@onready var lbl_founder_name: Label = $VBoxContainer/Panel/VBoxContainer/HBoxFounder/LblFounderValue
@onready var lbl_city: Label = $VBoxContainer/Panel/VBoxContainer/HBoxCity/LblCityValue
@onready var lbl_type: Label = $VBoxContainer/Panel/VBoxContainer/HBoxType/LblTypeValue
@onready var lbl_capital: Label = $VBoxContainer/Panel/VBoxContainer/HBoxCapital/LblCapitalValue

@onready var btn_start: Button = $VBoxContainer/BtnStart
@onready var btn_back: Button = $VBoxContainer/BtnBack

func _ready() -> void:
	# Populate fields from GameData
	lbl_studio_name.text = GameData.studio_name
	lbl_founder_name.text = GameData.founder_name
	lbl_city.text = GameData.city
	lbl_type.text = "Independent"
	lbl_capital.text = "₹10,000" # Placeholder, actual economy initializes next
	
	btn_start.pressed.connect(_on_start_pressed)
	btn_back.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/studio_setup.tscn")

func _on_start_pressed() -> void:
	# Initialize all game systems here (Step E)
	GameClock.current_week = 1
	Economy.currency = 10000
	
	# Save the initial game state
	SaveManager.save_game()
	
	# Go to Intro
	get_tree().change_scene_to_file("res://scenes/menu/intro.tscn")
