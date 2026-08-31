extends Control

# ---------------------------------------------------------------------------
# Step indices
# ---------------------------------------------------------------------------
const STEP_GENRE     := 0
const STEP_BUDGET    := 1
const STEP_CAST      := 2
const STEP_DIRECTOR  := 3
const STEP_CONFIRM   := 4
const STEP_PROGRESS  := 5
const STEP_DNA       := 6

# ---------------------------------------------------------------------------
# Node references (populated in _ready via $-paths)
# ---------------------------------------------------------------------------
@onready var step_panels: Array[Control] = []

# Step 0: Genre
@onready var genre_panel: PanelContainer    = $WizardPanel/VBox/GenrePanel
@onready var genre_btn_action: Button        = $WizardPanel/VBox/GenrePanel/VBox/GenreGrid/BtnAction
@onready var genre_btn_comedy: Button        = $WizardPanel/VBox/GenrePanel/VBox/GenreGrid/BtnComedy
@onready var genre_btn_drama: Button         = $WizardPanel/VBox/GenrePanel/VBox/GenreGrid/BtnDrama
@onready var genre_btn_scifi: Button         = $WizardPanel/VBox/GenrePanel/VBox/GenreGrid/BtnSciFi
@onready var genre_btn_thriller: Button      = $WizardPanel/VBox/GenrePanel/VBox/GenreGrid/BtnThriller
@onready var genre_btn_horror: Button        = $WizardPanel/VBox/GenrePanel/VBox/GenreGrid/BtnHorror
@onready var genre_next_btn: Button          = $WizardPanel/VBox/GenrePanel/VBox/NextBtn

# Step 1: Budget
@onready var budget_panel: PanelContainer   = $WizardPanel/VBox/BudgetPanel
@onready var budget_slider: HSlider          = $WizardPanel/VBox/BudgetPanel/VBox/BudgetSlider
@onready var budget_lbl: Label               = $WizardPanel/VBox/BudgetPanel/VBox/BudgetLbl
@onready var budget_warning: Label           = $WizardPanel/VBox/BudgetPanel/VBox/BudgetWarning
@onready var budget_next_btn: Button         = $WizardPanel/VBox/BudgetPanel/VBox/NextBtn

# Step 2: Cast
@onready var cast_panel: PanelContainer     = $WizardPanel/VBox/CastPanel
@onready var cast_list_vbox: VBoxContainer   = $WizardPanel/VBox/CastPanel/VBox/CastScroll/CastListVBox
@onready var cast_add_btn: Button            = $WizardPanel/VBox/CastPanel/VBox/AddCastBtn
@onready var cast_next_btn: Button           = $WizardPanel/VBox/CastPanel/VBox/NextBtn

# Step 3: Director
@onready var director_panel: PanelContainer = $WizardPanel/VBox/DirectorPanel
@onready var director_input: LineEdit        = $WizardPanel/VBox/DirectorPanel/VBox/DirectorInput
@onready var director_next_btn: Button       = $WizardPanel/VBox/DirectorPanel/VBox/NextBtn

# Step 4: Confirm
@onready var confirm_panel: PanelContainer  = $WizardPanel/VBox/ConfirmPanel
@onready var confirm_summary: Label          = $WizardPanel/VBox/ConfirmPanel/VBox/SummaryLbl
@onready var greenlight_btn: Button          = $WizardPanel/VBox/ConfirmPanel/VBox/GreenlightBtn
@onready var confirm_back_btn: Button        = $WizardPanel/VBox/ConfirmPanel/VBox/BackBtn

# Step 5: In production progress
@onready var progress_panel: PanelContainer = $WizardPanel/VBox/ProgressPanel
@onready var progress_lbl: Label             = $WizardPanel/VBox/ProgressPanel/VBox/ProgressLbl
@onready var progress_bar: ProgressBar       = $WizardPanel/VBox/ProgressPanel/VBox/ProgressBar

# Step 6: DNA results
@onready var dna_panel: PanelContainer      = $WizardPanel/VBox/DnaPanel
@onready var dna_result_lbl: Label           = $WizardPanel/VBox/DnaPanel/VBox/DnaResultLbl
@onready var dna_ok_btn: Button              = $WizardPanel/VBox/DnaPanel/VBox/OkBtn

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------
var _selected_genre: String = ""
var _selected_budget: int = 500
var _cast_names: Array[String] = []
var _director_name: String = ""
var _current_step: int = STEP_GENRE

# Placeholder cast pool
const PLACEHOLDER_CAST: Array[String] = [
	"Star A", "Star B", "Star C", "Rising Talent",
	"Veteran Lead", "Character Actor", "Method Performer"
]
var _available_cast: Array[String] = []

# ---------------------------------------------------------------------------
# Ready
# ---------------------------------------------------------------------------
func _ready() -> void:
	step_panels = [
		genre_panel, budget_panel, cast_panel,
		director_panel, confirm_panel, progress_panel, dna_panel
	]

	_available_cast = PLACEHOLDER_CAST.duplicate()

	# Genre buttons
	for btn in [genre_btn_action, genre_btn_comedy, genre_btn_drama,
				genre_btn_scifi, genre_btn_thriller, genre_btn_horror]:
		btn.pressed.connect(_on_genre_selected.bind(btn.text))
	genre_next_btn.pressed.connect(func(): _goto(STEP_BUDGET))
	genre_next_btn.disabled = true

	# Budget
	budget_slider.min_value = 100
	budget_slider.max_value = float(max(Economy.currency, 500))
	budget_slider.step = 100
	budget_slider.value = min(500.0, float(Economy.currency))
	budget_slider.value_changed.connect(_on_budget_changed)
	budget_next_btn.pressed.connect(func(): _goto(STEP_CAST))
	_on_budget_changed(budget_slider.value)

	# Cast
	cast_add_btn.pressed.connect(_on_add_cast_pressed)
	cast_next_btn.pressed.connect(func(): _goto(STEP_DIRECTOR))

	# Director
	director_input.text_changed.connect(_on_director_text_changed)
	director_next_btn.pressed.connect(func(): _goto(STEP_CONFIRM))
	director_next_btn.disabled = true

	# Confirm
	greenlight_btn.pressed.connect(_on_greenlight_pressed)
	confirm_back_btn.pressed.connect(func(): _goto(STEP_GENRE))

	# DNA ok
	dna_ok_btn.pressed.connect(_on_dna_ok_pressed)

	# Movie manager signals
	MovieManager.production_completed.connect(_on_production_completed)
	GameClock.week_passed.connect(_on_week_passed)

	# Start: if a production is already running, jump straight to it
	if MovieManager.active_production != null:
		_goto(STEP_PROGRESS)
		_update_progress_display()
	else:
		_goto(STEP_GENRE)

# ---------------------------------------------------------------------------
# Navigation
# ---------------------------------------------------------------------------
func _goto(step: int) -> void:
	_current_step = step
	for i in step_panels.size():
		step_panels[i].visible = (i == step)

	if step == STEP_CONFIRM:
		_refresh_confirm_summary()

# ---------------------------------------------------------------------------
# Genre step
# ---------------------------------------------------------------------------
func _on_genre_selected(genre_text: String) -> void:
	_selected_genre = genre_text
	genre_next_btn.disabled = false
	# Visual feedback: highlight chosen button (simple color toggle)
	for btn in [genre_btn_action, genre_btn_comedy, genre_btn_drama,
				genre_btn_scifi, genre_btn_thriller, genre_btn_horror]:
		btn.modulate = Color(0.7, 0.7, 0.7) if btn.text != genre_text else Color(1, 1, 1)

# ---------------------------------------------------------------------------
# Budget step
# ---------------------------------------------------------------------------
func _on_budget_changed(value: float) -> void:
	_selected_budget = int(value)
	budget_lbl.text = "Budget: %d   (Balance: %d)" % [_selected_budget, Economy.currency]
	var affordable: bool = _selected_budget <= Economy.currency
	budget_next_btn.disabled = not affordable
	budget_warning.visible = not affordable
	budget_warning.text = "Insufficient funds!"

# ---------------------------------------------------------------------------
# Cast step
# ---------------------------------------------------------------------------
func _on_add_cast_pressed() -> void:
	if _available_cast.is_empty():
		return
	var name_to_add: String = _available_cast.pop_front()
	_cast_names.append(name_to_add)
	_rebuild_cast_list()

func _rebuild_cast_list() -> void:
	for child in cast_list_vbox.get_children():
		child.queue_free()
	if _cast_names.is_empty():
		var lbl: Label = Label.new()
		lbl.text = "(No cast added yet)"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cast_list_vbox.add_child(lbl)
		return
	for c_name in _cast_names:
		var row: HBoxContainer = HBoxContainer.new()
		var lbl: Label = Label.new()
		lbl.text = c_name
		lbl.size_flags_horizontal = SIZE_EXPAND_FILL
		var remove_btn: Button = Button.new()
		remove_btn.text = "Remove"
		var captured_name: String = c_name
		remove_btn.pressed.connect(func():
			_cast_names.erase(captured_name)
			_available_cast.append(captured_name)
			_rebuild_cast_list()
		)
		row.add_child(lbl)
		row.add_child(remove_btn)
		cast_list_vbox.add_child(row)
	cast_add_btn.disabled = _available_cast.is_empty()

# ---------------------------------------------------------------------------
# Director step
# ---------------------------------------------------------------------------
func _on_director_text_changed(new_text: String) -> void:
	_director_name = new_text.strip_edges()
	director_next_btn.disabled = _director_name.is_empty()

# ---------------------------------------------------------------------------
# Confirm step
# ---------------------------------------------------------------------------
func _refresh_confirm_summary() -> void:
	var cast_str: String = ", ".join(_cast_names) if not _cast_names.is_empty() else "(none)"
	confirm_summary.text = (
		"Genre:    %s\nBudget:   %d\nDirector: %s\nCast:     %s\n\nBalance after greenlight: %d"
		% [_selected_genre, _selected_budget, _director_name, cast_str,
		   Economy.currency - _selected_budget]
	)
	greenlight_btn.disabled = (_selected_genre.is_empty() or _director_name.is_empty())

func _on_greenlight_pressed() -> void:
	# Build title: "Genre: Director's <title>" — simple placeholder
	var title: String = "%s: %s's Film" % [_selected_genre, _director_name]
	var ok: bool = MovieManager.greenlight_movie(
		title,
		_selected_genre,
		_selected_budget,
		_director_name,
		_cast_names,
		{}
	)
	if ok:
		_goto(STEP_PROGRESS)
		_update_progress_display()

# ---------------------------------------------------------------------------
# Production progress step
# ---------------------------------------------------------------------------
func _on_week_passed(_week_num: int) -> void:
	if _current_step == STEP_PROGRESS and MovieManager.active_production != null:
		_update_progress_display()

func _update_progress_display() -> void:
	var prod: MovieData = MovieManager.active_production
	if prod == null:
		return
	var start_week: int = MovieManager._production_start_week
	var elapsed: int = GameClock.current_week - start_week
	var total: int = MovieManager.PRODUCTION_DURATION_WEEKS
	var pct: float = clampf(float(elapsed) / float(total), 0.0, 1.0)

	progress_bar.value = pct * 100.0
	progress_lbl.text = (
		"In Production: '%s'\nGenre: %s | Budget: %d\nDirector: %s\n\nWeek %d / %d"
		% [prod.movie_title, prod.genre, prod.budget, prod.director_name, elapsed, total]
	)

func _on_production_completed(movie: MovieData) -> void:
	_goto(STEP_DNA)
	_render_dna_panel(movie)

# ---------------------------------------------------------------------------
# DNA results step
# ---------------------------------------------------------------------------
func _render_dna_panel(movie: MovieData) -> void:
	dna_result_lbl.text = (
		"'%s' is ready for release!\n\n"
		% movie.movie_title
		+ "Story:       %5.1f\n" % movie.dna_story
		+ "Direction:   %5.1f\n" % movie.dna_direction
		+ "Acting:      %5.1f\n" % movie.dna_acting
		+ "Music:       %5.1f\n" % movie.dna_music
		+ "Visuals:     %5.1f\n" % movie.dna_visuals
		+ "Pacing:      %5.1f\n" % movie.dna_pacing
		+ "Originality: %5.1f\n\n" % movie.dna_originality
		+ "Mass Appeal:     %5.1f\n" % movie.dna_mass_appeal
		+ "Critical Appeal: %5.1f\n" % movie.dna_critical_appeal
	)

func _on_dna_ok_pressed() -> void:
	# Reset wizard state for next production
	_selected_genre = ""
	_selected_budget = 500
	_cast_names.clear()
	_director_name = ""
	_available_cast = PLACEHOLDER_CAST.duplicate()
	_rebuild_cast_list()
	genre_next_btn.disabled = true
	for btn in [genre_btn_action, genre_btn_comedy, genre_btn_drama,
				genre_btn_scifi, genre_btn_thriller, genre_btn_horror]:
		btn.modulate = Color(1, 1, 1)
	_goto(STEP_GENRE)
