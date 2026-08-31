extends Control

@onready var week_lbl: Label = $VBoxContainer/TopBar/MarginContainer/HBoxContainer/WeekLbl
@onready var currency_lbl: Label = $VBoxContainer/TopBar/MarginContainer/HBoxContainer/CurrencyLbl
@onready var advance_week_btn: Button = $VBoxContainer/TopBar/MarginContainer/HBoxContainer/AdvanceWeekBtn

@onready var tab_container: TabContainer = $VBoxContainer/MainContent/TabContainer

@onready var btn_office: Button = $VBoxContainer/BottomNav/MarginContainer/HBoxContainer/BtnOffice
@onready var btn_movies: Button = $VBoxContainer/BottomNav/MarginContainer/HBoxContainer/BtnMovies
@onready var btn_people: Button = $VBoxContainer/BottomNav/MarginContainer/HBoxContainer/BtnPeople
@onready var btn_finance: Button = $VBoxContainer/BottomNav/MarginContainer/HBoxContainer/BtnFinance
@onready var btn_news: Button = $VBoxContainer/BottomNav/MarginContainer/HBoxContainer/BtnNews

@onready var notification_panel: PanelContainer = $NotificationPanel
@onready var notification_label: Label = $NotificationPanel/MarginContainer/HBoxContainer/Label
@onready var notification_close_btn: Button = $NotificationPanel/MarginContainer/HBoxContainer/CloseBtn

func _ready() -> void:
	# Connect top bar
	advance_week_btn.pressed.connect(_on_advance_week_pressed)
	GameClock.week_passed.connect(_on_week_passed)
	Economy.currency_changed.connect(_on_currency_changed)
	
	# Connect notification signal
	ContractManager.contract_delivered.connect(_on_contract_delivered)
	notification_close_btn.pressed.connect(_on_notification_close)
	notification_panel.visible = false
	
	# Connect bottom navigation
	btn_office.pressed.connect(func(): tab_container.current_tab = 0)
	btn_movies.pressed.connect(func(): print("Movies feature not yet implemented"))
	btn_people.pressed.connect(func(): tab_container.current_tab = 1)
	btn_finance.pressed.connect(func(): print("Finance feature not yet implemented"))
	btn_news.pressed.connect(func(): print("News feature not yet implemented"))
	
	_update_top_bar()

func _update_top_bar() -> void:
	week_lbl.text = "Week: %d" % GameClock.current_week
	currency_lbl.text = "Balance: %d" % Economy.currency

func _on_week_passed(_week_num: int) -> void:
	_update_top_bar()

func _on_currency_changed(_new_balance: int) -> void:
	_update_top_bar()

func _on_advance_week_pressed() -> void:
	GameClock.advance_week()

func _on_contract_delivered(title: String, payout: int, on_time: bool) -> void:
	var status_str: String = "ON TIME! Payout: %d" % payout if on_time else "LATE (0.9x penalty)! Payout: %d" % payout
	notification_label.text = "Contract Completed: '%s'\nResult: %s" % [title, status_str]
	notification_panel.visible = true

func _on_notification_close() -> void:
	notification_panel.visible = false
