extends Node

# Preload so MovieData type resolves before Godot's class_name cache is warm
const MovieDataScript = preload("res://resources/movie_data.gd")

signal movie_greenlit(movie: Resource)
signal movie_dna_calculated(movie: Resource)
signal production_completed(movie: Resource)

const PRODUCTION_DURATION_WEEKS: int = 4

var active_production: Resource = null
var completed_movies: Array = []

# Tracks which week production started, to trigger completion
var _production_start_week: int = -1

func _ready() -> void:
	GameClock.week_passed.connect(_on_week_passed)

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Attempts to greenlight a new movie. Returns false if:
##   - another production is already active
##   - budget is unaffordable
func greenlight_movie(
	title: String,
	genre: String,
	budget: int,
	director: String,
	cast: Array,
	crew: Dictionary
) -> bool:
	if active_production != null:
		print("Cannot greenlight '%s': A production is already active ('%s')." % [title, active_production.movie_title])
		return false

	if not Economy.try_spend(budget, "Greenlight movie '%s'" % title):
		return false

	var movie: Resource = MovieDataScript.new()
	movie.movie_title = title
	movie.genre = genre
	movie.budget = budget
	movie.director_name = director
	movie.cast = cast.duplicate()
	movie.crew = crew.duplicate()
	movie.status = "in_production"

	active_production = movie
	_production_start_week = GameClock.current_week

	print("Movie greenlighted: '%s' | Genre: %s | Budget: %d | Director: %s | Cast: %s" % [
		title, genre, budget, director, str(cast)
	])
	movie_greenlit.emit(movie)
	return true

## Calculates Movie DNA from cast size, director quality, and budget tier.
## Phase 1 placeholder formula — see PROGRESS.md Deviations.
## director_quality: 0-100 stand-in (default 50 when unknown)
func calculate_movie_dna(movie: Resource, director_quality: float = 50.0) -> void:
	# Acting: cast size proxy — each actor contributes 15 pts, capped at 100
	movie.dna_acting = clampf(movie.cast.size() * 15.0, 0.0, 100.0)

	# Direction: director quality stand-in
	movie.dna_direction = clampf(director_quality, 0.0, 100.0)

	# Budget-derived baseline for all story/craft attributes
	var budget_score: float = clampf(movie.budget / 100.0, 20.0, 90.0)

	movie.dna_story = budget_score
	movie.dna_music = budget_score
	movie.dna_visuals = budget_score
	movie.dna_pacing = budget_score
	movie.dna_originality = budget_score

	# Composite: mass appeal (blockbuster weighting)
	movie.dna_mass_appeal = clampf(
		0.5 * movie.dna_acting + 0.3 * movie.dna_visuals + 0.2 * movie.dna_music,
		0.0, 100.0
	)

	# Composite: critical appeal (auteur weighting)
	movie.dna_critical_appeal = clampf(
		0.5 * movie.dna_story + 0.3 * movie.dna_direction + 0.2 * movie.dna_originality,
		0.0, 100.0
	)

	print("DNA calculated for '%s': acting=%.1f dir=%.1f story=%.1f visuals=%.1f music=%.1f pacing=%.1f orig=%.1f | mass=%.1f crit=%.1f" % [
		movie.movie_title,
		movie.dna_acting, movie.dna_direction, movie.dna_story,
		movie.dna_visuals, movie.dna_music, movie.dna_pacing,
		movie.dna_originality, movie.dna_mass_appeal, movie.dna_critical_appeal
	])
	movie_dna_calculated.emit(movie)

## Finalises production: calculates DNA, sets status to "ready", archives movie.
func complete_production(movie: Resource) -> void:
	calculate_movie_dna(movie)
	movie.status = "ready"

	if active_production == movie:
		active_production = null
		_production_start_week = -1

	if movie not in completed_movies:
		completed_movies.append(movie)

	print("Production complete: '%s' is ready for release!" % movie.movie_title)
	production_completed.emit(movie)

# ---------------------------------------------------------------------------
# Internal
# ---------------------------------------------------------------------------

func _on_week_passed(_week_num: int) -> void:
	if active_production == null:
		return
	var weeks_elapsed: int = GameClock.current_week - _production_start_week
	if weeks_elapsed >= PRODUCTION_DURATION_WEEKS:
		complete_production(active_production)
