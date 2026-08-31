extends Control

@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var advance_week_btn: Button = $VBoxContainer/AdvanceWeekBtn
@onready var add_100_btn: Button = $VBoxContainer/Add100Btn
@onready var try_spend_50_btn: Button = $VBoxContainer/TrySpend50Btn

func _ready() -> void:
	# Connect to autoload signals
	GameClock.week_passed.connect(_on_week_passed)
	Economy.currency_changed.connect(_on_currency_changed)
	
	# Connect button signals to autoload methods
	advance_week_btn.pressed.connect(_on_advance_week_pressed)
	add_100_btn.pressed.connect(_on_add_100_pressed)
	try_spend_50_btn.pressed.connect(_on_try_spend_50_pressed)
	
	# Update initial display
	_update_label()

func _update_label() -> void:
	status_label.text = "Week: %d | Currency: %d" % [GameClock.current_week, Economy.currency]

func _on_week_passed(_week_number: int) -> void:
	_update_label()

func _on_currency_changed(_new_amount: int) -> void:
	_update_label()

func _on_advance_week_pressed() -> void:
	GameClock.advance_week()

func _on_add_100_pressed() -> void:
	Economy.add_currency(100)

func _on_try_spend_50_pressed() -> void:
	Economy.try_spend(50, "Debug Spend")
