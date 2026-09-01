extends Node

const ReleaseDataScript = preload("res://resources/release_data.gd")
const DistributorDataScript = preload("res://resources/distributor_data.gd")

signal release_started(release: Resource)
signal release_week_processed(release: Resource, week_bo: int, week_audience: int)
signal release_completed(release: Resource)

const MAX_THEATRICAL_WEEKS: int = 8
const TICKET_PRICE: int = 15
const BASE_DEMAND_MULTIPLIER: float = 5.0

const MARKETING_TIERS: Dictionary = {
	"None": {"cost": 0, "buzz_bonus": 0.0},
	"Social": {"cost": 100, "buzz_bonus": 5.0},
	"Trailer": {"cost": 500, "buzz_bonus": 15.0},
	"Television": {"cost": 2000, "buzz_bonus": 40.0},
	"Massive": {"cost": 5000, "buzz_bonus": 80.0}
}

var active_releases: Array = []
var completed_releases: Array = []
var available_distributors: Array = []

func _ready() -> void:
	GameClock.week_passed.connect(_on_week_passed)
	_load_distributors()

func _load_distributors() -> void:
	# Load from res://data/distributors/
	var path: String = "res://data/distributors/"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var res = load(path + file_name)
				if res != null:
					available_distributors.append(res)
			file_name = dir.get_next()

func get_marketing_cost(tier: String) -> int:
	if MARKETING_TIERS.has(tier):
		return MARKETING_TIERS[tier]["cost"]
	return 0

func setup_release(movie: Resource, distributor: Resource, marketing_tier: String) -> Resource:
	var marketing_cost: int = get_marketing_cost(marketing_tier)
	if marketing_cost > 0:
		if not Economy.try_spend(marketing_cost, "Marketing: %s" % movie.movie_title):
			return null
	
	var release: Resource = ReleaseDataScript.new()
	release.movie_data = movie
	release.distributor = distributor
	release.marketing_spend = marketing_cost
	release.marketing_tier = marketing_tier
	
	# Calculate buzz
	var buzz_bonus: float = MARKETING_TIERS[marketing_tier]["buzz_bonus"] if MARKETING_TIERS.has(marketing_tier) else 0.0
	var initial_buzz: float = (movie.dna_mass_appeal * 0.3) + (distributor.popularity * 0.2) + buzz_bonus
	# Random variation +/- 10%
	var buzz_variance: float = randf_range(0.9, 1.1)
	release.buzz = clampf(initial_buzz * buzz_variance, 0.0, 100.0)
	
	# Initial reviews
	_generate_reviews(release, movie)
	
	# Initial WOM based on audience rating and buzz
	release.word_of_mouth = clampf((release.audience_rating * 15.0) + (release.buzz * 0.2), 0.0, 100.0)
	
	release.release_week = GameClock.current_week
	release.current_week_in_release = 1
	release.screens = distributor.screen_access
	release.status = "released"
	movie.status = "released"
	
	active_releases.append(release)
	print("Release started for '%s' with '%s' (Buzz: %.1f)" % [movie.movie_title, distributor.display_name, release.buzz])
	release_started.emit(release)
	
	# Immediately process week 1? No, usually it processes at the next week_passed signal.
	# But if we want week 1 results immediately, we could. Let's wait for the week tick.
	return release

func _generate_reviews(release: Resource, movie: Resource) -> void:
	# Critic rating heavily favors dna_critical_appeal
	var crit_base: float = movie.dna_critical_appeal / 20.0 # 0-5 scale
	var crit_variance: float = randf_range(-0.5, 0.5)
	release.critic_rating = clampf(crit_base + crit_variance, 0.0, 5.0)
	
	# Audience rating favors dna_mass_appeal
	var aud_base: float = movie.dna_mass_appeal / 20.0
	var aud_variance: float = randf_range(-0.5, 0.5)
	release.audience_rating = clampf(aud_base + aud_variance, 0.0, 5.0)

func _on_week_passed(_week_num: int) -> void:
	var releases_to_complete: Array = []
	
	for release in active_releases:
		_process_weekly_performance(release)
		if release.weeks_screened >= MAX_THEATRICAL_WEEKS:
			releases_to_complete.append(release)
		elif release.weekly_box_office.back() < 50: # Drop if it makes virtually no money
			releases_to_complete.append(release)
			
	for release in releases_to_complete:
		_complete_release(release)

func _process_weekly_performance(release: Resource) -> void:
	release.weeks_screened += 1
	release.current_week_in_release = release.weeks_screened
	
	var movie: Resource = release.movie_data
	var dist: Resource = release.distributor
	
	# Decay multiplier based on week (Week 1 = 1.0, Week 2 = 0.6, Week 3 = 0.3...)
	var decay: float = pow(0.6, release.weeks_screened - 1)
	
	# WOM modifier: > 50 increases legs, < 50 decreases them
	var wom_mod: float = (release.word_of_mouth / 50.0) # 0.0 to 2.0
	decay = clampf(decay * wom_mod, 0.05, 1.5)
	
	# Base demand
	var demand: float = BASE_DEMAND_MULTIPLIER * (movie.dna_mass_appeal / 50.0)
	var buzz_mod: float = (release.buzz / 50.0)
	
	# Random variance each week
	var week_variance: float = randf_range(0.85, 1.15)
	
	# Calculate audience
	var raw_audience: float = demand * buzz_mod * dist.reach * release.screens * decay * week_variance
	var week_audience: int = int(maxf(0.0, raw_audience))
	
	var week_bo: int = week_audience * TICKET_PRICE
	var net_bo: int = int(week_bo * (1.0 - dist.revenue_share))
	
	release.weekly_audience.append(week_audience)
	release.weekly_box_office.append(week_bo)
	
	release.total_audience += week_audience
	release.total_box_office += week_bo
	
	# Earn the money
	if net_bo > 0:
		Economy.add_currency(net_bo)
		print("Box Office: %s (Week %d) earned %d" % [movie.movie_title, release.weeks_screened, net_bo])
		
	# Update screens (drop screens if doing poorly, but simple logic for now: fixed or slight decay)
	release.screens = int(maxf(10.0, release.screens * 0.9))
	
	# Decay buzz and WOM slightly
	release.buzz = clampf(release.buzz * 0.8, 0.0, 100.0)
	
	release_week_processed.emit(release, week_bo, week_audience)

func _complete_release(release: Resource) -> void:
	release.status = "completed"
	active_releases.erase(release)
	completed_releases.append(release)
	
	# Profit/Loss simple check
	var net_revenue: int = int(release.total_box_office * (1.0 - release.distributor.revenue_share))
	var total_cost: int = release.movie_data.budget + release.marketing_spend
	var profit: int = net_revenue - total_cost
	var roi: float = float(net_revenue) / maxf(1.0, float(total_cost))
	
	if roi >= 3.0:
		release.result_classification = "Blockbuster"
	elif roi >= 2.0:
		release.result_classification = "Super Hit"
	elif roi >= 1.2:
		release.result_classification = "Hit"
	elif roi >= 0.8:
		release.result_classification = "Average"
	elif roi >= 0.4:
		release.result_classification = "Flop"
	else:
		release.result_classification = "Disaster"
		
	print("Release finished: '%s'. BO: %d, Profit: %d (%s)" % [release.movie_data.movie_title, release.total_box_office, profit, release.result_classification])
	release_completed.emit(release)
