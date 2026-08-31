class_name MovieManagerTest
extends Node

# Preload so MovieData type is resolvable in headless compilation
const MovieDataScript = preload("res://resources/movie_data.gd")

var passes: int = 0
var fails: int = 0

func run_all() -> Dictionary:
	passes = 0
	fails = 0
	print("\n=== RUNNING MOVIE MANAGER TESTS ===")
	test_greenlight_deducts_budget()
	test_greenlight_refuses_when_unaffordable()
	test_greenlight_refuses_second_active_production()
	test_dna_values_in_range_small()
	test_dna_values_in_range_large()
	test_dna_mass_vs_critical_divergence()
	print("MovieManager Tests Summary: %d PASSED, %d FAILED" % [passes, fails])
	return {"passes": passes, "fails": fails}

func assert_true(condition: bool, message: String) -> void:
	if condition:
		print("[PASS] %s" % message)
		passes += 1
	else:
		print("[FAIL] %s" % message)
		fails += 1

func _reset_manager() -> void:
	MovieManager.active_production = null
	MovieManager.completed_movies.clear()
	MovieManager._production_start_week = -1

# ---------------------------------------------------------------------------
# Test: greenlight deducts budget from Economy
# ---------------------------------------------------------------------------
func test_greenlight_deducts_budget() -> void:
	_reset_manager()
	Economy.currency = 5000
	var before: int = Economy.currency

	var ok: bool = MovieManager.greenlight_movie(
		"Test Film Alpha", "Drama", 2000, "Director One",
		["Cast A", "Cast B"], {}
	)
	assert_true(ok, "greenlight_movie() returned true when budget (2000) <= balance (5000)")
	assert_true(Economy.currency == before - 2000,
		"Economy.currency decreased by 2000 (was %d, now %d)" % [before, Economy.currency])
	assert_true(MovieManager.active_production != null,
		"active_production is set after successful greenlight")
	assert_true(MovieManager.active_production.movie_title == "Test Film Alpha",
		"active_production.movie_title matches 'Test Film Alpha'")
	assert_true(MovieManager.active_production.status == "in_production",
		"active_production.status is 'in_production'")

# ---------------------------------------------------------------------------
# Test: greenlight refused when budget > balance
# ---------------------------------------------------------------------------
func test_greenlight_refuses_when_unaffordable() -> void:
	_reset_manager()
	Economy.currency = 500

	var ok: bool = MovieManager.greenlight_movie(
		"Too Expensive Film", "Action", 5000, "Director Two",
		[], {}
	)
	assert_true(not ok,
		"greenlight_movie() returned false when budget (5000) > balance (500)")
	assert_true(Economy.currency == 500,
		"Economy.currency unchanged (500) after refused greenlight")
	assert_true(MovieManager.active_production == null,
		"active_production remains null after refused greenlight")

# ---------------------------------------------------------------------------
# Test: second greenlight refused while one is active
# ---------------------------------------------------------------------------
func test_greenlight_refuses_second_active_production() -> void:
	_reset_manager()
	Economy.currency = 10000

	var first_ok: bool = MovieManager.greenlight_movie(
		"First Film", "Comedy", 1000, "Dir A", [], {}
	)
	assert_true(first_ok, "First greenlight succeeded")

	var currency_after_first: int = Economy.currency

	var second_ok: bool = MovieManager.greenlight_movie(
		"Second Film", "Horror", 1000, "Dir B", [], {}
	)
	assert_true(not second_ok,
		"Second greenlight refused while First Film is still in production")
	assert_true(Economy.currency == currency_after_first,
		"Economy.currency unchanged by refused second greenlight")
	assert_true(MovieManager.active_production.movie_title == "First Film",
		"active_production still holds 'First Film' after refused second greenlight")

# ---------------------------------------------------------------------------
# Test: DNA values within 0-100 — small cast / low budget
# ---------------------------------------------------------------------------
func test_dna_values_in_range_small() -> void:
	# Use MovieDataScript.new() to avoid class_name resolution issues headlessly
	var movie: Resource = MovieDataScript.new()
	movie.movie_title = "Tiny Indie"
	movie.cast = ["Solo Actor"]   # 1 cast member
	movie.budget = 200            # budget_score = clamp(200/100, 20, 90) = 20

	MovieManager.calculate_movie_dna(movie, 30.0)   # modest director quality

	_assert_dna_in_range(movie, "small-cast/low-budget")

# ---------------------------------------------------------------------------
# Test: DNA values within 0-100 — large cast / high budget
# ---------------------------------------------------------------------------
func test_dna_values_in_range_large() -> void:
	var movie: Resource = MovieDataScript.new()
	movie.movie_title = "Big Blockbuster"
	movie.cast = ["Star1", "Star2", "Star3", "Star4", "Star5", "Star6"]
	movie.budget = 9000           # budget_score = clamp(9000/100, 20, 90) = 90

	MovieManager.calculate_movie_dna(movie, 90.0)   # top director quality

	_assert_dna_in_range(movie, "large-cast/high-budget")

func _assert_dna_in_range(movie: Resource, label: String) -> void:
	var fields: Dictionary = {
		"dna_story": movie.dna_story,
		"dna_direction": movie.dna_direction,
		"dna_acting": movie.dna_acting,
		"dna_music": movie.dna_music,
		"dna_visuals": movie.dna_visuals,
		"dna_pacing": movie.dna_pacing,
		"dna_originality": movie.dna_originality,
		"dna_mass_appeal": movie.dna_mass_appeal,
		"dna_critical_appeal": movie.dna_critical_appeal
	}
	for field_name in fields.keys():
		var v: float = fields[field_name]
		assert_true(v >= 0.0 and v <= 100.0,
			"[%s] %s = %.1f is within [0, 100]" % [label, field_name, v])

# ---------------------------------------------------------------------------
# Test: mass_appeal vs critical_appeal divergence (blockbuster vs. darling)
# ---------------------------------------------------------------------------
func test_dna_mass_vs_critical_divergence() -> void:
	# Blockbuster: big cast (high acting), mediocre director, low-mid budget
	# mass_appeal  = 0.5*90 + 0.3*20 + 0.2*20 = 45 + 6 + 4 = 55
	# crit_appeal  = 0.5*20 + 0.3*30 + 0.2*20 = 10 + 9 + 4 = 23
	var blockbuster: Resource = MovieDataScript.new()
	blockbuster.movie_title = "Summer Blockbuster"
	blockbuster.cast = ["Star1", "Star2", "Star3", "Star4", "Star5", "Star6"]  # acting = 90
	blockbuster.budget = 2000   # budget_score = clamp(20, 20, 90) = 20
	MovieManager.calculate_movie_dna(blockbuster, 30.0)

	assert_true(blockbuster.dna_mass_appeal > blockbuster.dna_critical_appeal,
		"Blockbuster: mass_appeal (%.1f) > critical_appeal (%.1f)" % [
			blockbuster.dna_mass_appeal, blockbuster.dna_critical_appeal])
	assert_true(blockbuster.dna_mass_appeal - blockbuster.dna_critical_appeal >= 10.0,
		"Blockbuster: mass/crit gap >= 10 pts (gap = %.1f)" % (
			blockbuster.dna_mass_appeal - blockbuster.dna_critical_appeal))

	# Critical darling: solo actor (low acting), top director, big budget
	# mass_appeal  = 0.5*15 + 0.3*90 + 0.2*90 = 7.5 + 27 + 18 = 52.5
	# crit_appeal  = 0.5*90 + 0.3*95 + 0.2*90 = 45 + 28.5 + 18 = 91.5
	var darling: Resource = MovieDataScript.new()
	darling.movie_title = "Auteur Piece"
	darling.cast = ["Solo Lead"]   # acting = clamp(15, 0, 100) = 15
	darling.budget = 9000          # budget_score = 90
	MovieManager.calculate_movie_dna(darling, 95.0)

	assert_true(darling.dna_critical_appeal > darling.dna_mass_appeal,
		"Critical darling: critical_appeal (%.1f) > mass_appeal (%.1f)" % [
			darling.dna_critical_appeal, darling.dna_mass_appeal])
	assert_true(darling.dna_critical_appeal - darling.dna_mass_appeal >= 10.0,
		"Critical darling: crit/mass gap >= 10 pts (gap = %.1f)" % (
			darling.dna_critical_appeal - darling.dna_mass_appeal))
