extends Control

@onready var studio_name_edit: LineEdit = $VBoxContainer/Form/StudioNameEdit
@onready var founder_name_edit: LineEdit = $VBoxContainer/Form/FounderNameEdit
@onready var city_options: OptionButton = $VBoxContainer/Form/CityOptions
@onready var btn_create: Button = $VBoxContainer/BtnCreate
@onready var btn_back: Button = $VBoxContainer/BtnBack

func _ready() -> void:
	btn_create.pressed.connect(_on_create_pressed)
	btn_back.pressed.connect(_on_back_pressed)
	
	# Populate cities
	var cities = ["Mumbai", "Hyderabad", "Chennai", "Bengaluru", "Delhi", "Kolkata"]
	for city in cities:
		city_options.add_item(city)
		
	_validate_form()
	studio_name_edit.text_changed.connect(func(_t): _validate_form())

func _validate_form() -> void:
	btn_create.disabled = studio_name_edit.text.strip_edges().is_empty()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")

func _on_create_pressed() -> void:
	GameData.studio_name = studio_name_edit.text.strip_edges()
	GameData.founder_name = founder_name_edit.text.strip_edges()
	GameData.city = city_options.get_item_text(city_options.selected)
	
	get_tree().change_scene_to_file("res://scenes/menu/studio_confirmation.tscn")
