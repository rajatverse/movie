extends Control

@onready var setup_panel: VBoxContainer = $ScrollContainer/MarginContainer/VBoxContainer/SetupPanel
@onready var active_panel: VBoxContainer = $ScrollContainer/MarginContainer/VBoxContainer/ActivePanel
@onready var result_panel: VBoxContainer = $ScrollContainer/MarginContainer/VBoxContainer/ResultPanel
@onready var empty_label: Label = $ScrollContainer/MarginContainer/VBoxContainer/EmptyLabel

# Setup Panel UI
@onready var movie_select: OptionButton = setup_panel.get_node("MovieSelect")
@onready var distributor_select: OptionButton = setup_panel.get_node("DistributorSelect")
@onready var marketing_select: OptionButton = setup_panel.get_node("MarketingSelect")
@onready var cost_label: Label = setup_panel.get_node("CostLabel")
@onready var release_btn: Button = setup_panel.get_node("ReleaseButton")

# Active Panel UI
@onready var title_label: Label = active_panel.get_node("Header/TitleLabel")
@onready var info_label: Label = active_panel.get_node("Header/InfoLabel")
@onready var week_label: Label = active_panel.get_node("WeekLabel")
@onready var screens_label: Label = active_panel.get_node("Stats/ScreensLabel")
@onready var audience_label: Label = active_panel.get_node("Stats/AudienceLabel")
@onready var bo_label: Label = active_panel.get_node("Stats/BOLabel")
@onready var critic_label: Label = active_panel.get_node("Reviews/CriticLabel")
@onready var aud_review_label: Label = active_panel.get_node("Reviews/AudienceReviewLabel")
@onready var wom_label: Label = active_panel.get_node("Reviews/WOMLabel")
@onready var total_bo_label: Label = active_panel.get_node("TotalBOLabel")
@onready var next_week_btn: Button = active_panel.get_node("NextWeekButton")

# Result Panel UI
@onready var result_title_label: Label = result_panel.get_node("ResultTitleLabel")
@onready var class_label: Label = result_panel.get_node("ClassLabel")
@onready var details_label: Label = result_panel.get_node("DetailsLabel")
@onready var back_btn: Button = result_panel.get_node("BackButton")

var current_release: Resource = null
var ready_movies: Array = []

func _ready() -> void:
	ReleaseManager.release_started.connect(_on_release_started)
	ReleaseManager.release_week_processed.connect(_on_release_week_processed)
	ReleaseManager.release_completed.connect(_on_release_completed)
	
	movie_select.item_selected.connect(func(_idx): _update_setup_cost())
	marketing_select.item_selected.connect(func(_idx): _update_setup_cost())
	release_btn.pressed.connect(_on_release_button_pressed)
	next_week_btn.pressed.connect(func(): GameClock.advance_week())
	back_btn.pressed.connect(_refresh_view)
	
	_refresh_view()

func _refresh_view() -> void:
	current_release = null
	if ReleaseManager.active_releases.size() > 0:
		_show_active_release(ReleaseManager.active_releases[0])
	else:
		_show_setup()

func _show_setup() -> void:
	active_panel.hide()
	result_panel.hide()
	
	ready_movies.clear()
	for m in MovieManager.completed_movies:
		if m.status == "ready":
			ready_movies.append(m)
			
	if ready_movies.size() == 0:
		setup_panel.hide()
		empty_label.show()
		return
		
	empty_label.hide()
	setup_panel.show()
	
	movie_select.clear()
	for m in ready_movies:
		movie_select.add_item(m.movie_title)
		
	distributor_select.clear()
	for d in ReleaseManager.available_distributors:
		distributor_select.add_item(d.display_name)
		
	marketing_select.clear()
	for m_key in ReleaseManager.MARKETING_TIERS.keys():
		marketing_select.add_item(m_key)
		
	_update_setup_cost()

func _update_setup_cost() -> void:
	var m_idx = marketing_select.selected
	if m_idx < 0: return
	var tier = marketing_select.get_item_text(m_idx)
	var cost = ReleaseManager.get_marketing_cost(tier)
	cost_label.text = "Marketing Cost: %s" % _format_currency(cost)
	release_btn.disabled = not Economy.can_afford(cost)

func _on_release_button_pressed() -> void:
	if movie_select.selected < 0 or distributor_select.selected < 0 or marketing_select.selected < 0:
		return
	
	var movie = ready_movies[movie_select.selected]
	var dist = ReleaseManager.available_distributors[distributor_select.selected]
	var tier = marketing_select.get_item_text(marketing_select.selected)
	
	var release = ReleaseManager.setup_release(movie, dist, tier)
	if release:
		_show_active_release(release)

func _show_active_release(release: Resource) -> void:
	current_release = release
	setup_panel.hide()
	result_panel.hide()
	empty_label.hide()
	active_panel.show()
	
	_update_active_ui(release, 0, 0)

func _update_active_ui(release: Resource, last_wk_bo: int, last_wk_aud: int) -> void:
	title_label.text = release.movie_data.movie_title
	info_label.text = "Distributor: %s | Marketing: %s | Buzz: %.1f" % [release.distributor.display_name, release.marketing_tier, release.buzz]
	week_label.text = "WEEK %d" % release.current_week_in_release
	
	screens_label.text = "Screens: %s" % _format_number(release.screens)
	audience_label.text = "Week Audience: %s" % _format_number(last_wk_aud)
	bo_label.text = "Week Box Office: %s" % _format_currency(last_wk_bo)
	
	critic_label.text = "Critics: %.1f / 5.0" % release.critic_rating
	aud_review_label.text = "Audience: %.1f / 5.0" % release.audience_rating
	
	var wom_bars = ""
	for i in range(10):
		if i < int(release.word_of_mouth / 10.0):
			wom_bars += "█"
		else:
			wom_bars += "░"
	wom_label.text = "Word of Mouth:\n" + wom_bars
	
	total_bo_label.text = "Total Box Office: %s" % _format_currency(release.total_box_office)

func _on_release_started(release: Resource) -> void:
	if current_release == null:
		_show_active_release(release)

func _on_release_week_processed(release: Resource, week_bo: int, week_audience: int) -> void:
	if current_release == release:
		_update_active_ui(release, week_bo, week_audience)

func _on_release_completed(release: Resource) -> void:
	if current_release == release:
		current_release = null
		_show_result(release)

func _show_result(release: Resource) -> void:
	active_panel.hide()
	result_panel.show()
	
	result_title_label.text = "FINAL RESULTS: " + release.movie_data.movie_title
	class_label.text = "Result: " + release.result_classification
	
	var net_rev = int(release.total_box_office * (1.0 - release.distributor.revenue_share))
	var cost = release.movie_data.budget + release.marketing_spend
	var profit = net_rev - cost
	
	details_label.text = "Genre: %s\nDistributor: %s (%.0f%% Share)\nTotal Weeks: %d\nTotal Audience: %s\n" % [
		release.movie_data.genre, release.distributor.display_name, release.distributor.revenue_share * 100.0, release.weeks_screened, _format_number(release.total_audience)
	]
	details_label.text += "Critic Rating: %.1f | Audience Rating: %.1f\n\n" % [release.critic_rating, release.audience_rating]
	details_label.text += "Total Box Office: %s\nStudio Share: %s\nCosts (Prod+Mktg): %s\nProfit/Loss: %s" % [
		_format_currency(release.total_box_office), _format_currency(net_rev), _format_currency(cost), _format_currency(profit)
	]

func _format_currency(value: int) -> String:
	var string_val = str(abs(value))
	var formatted = ""
	var length = string_val.length()
	for i in range(length):
		if i > 0 and i % 3 == 0:
			formatted = "," + formatted
		formatted = string_val[length - 1 - i] + formatted
	
	if value < 0:
		return "-$" + formatted
	return "$" + formatted

func _format_number(value: int) -> String:
	var string_val = str(abs(value))
	var formatted = ""
	var length = string_val.length()
	for i in range(length):
		if i > 0 and i % 3 == 0:
			formatted = "," + formatted
		formatted = string_val[length - 1 - i] + formatted
	
	if value < 0:
		return "-" + formatted
	return formatted
