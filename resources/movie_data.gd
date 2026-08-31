class_name MovieData
extends Resource

@export var movie_title: String = ""
@export var genre: String = ""
@export var budget: int = 0
@export var director_name: String = ""
@export var cast: Array = []
@export var crew: Dictionary = {}  # role -> staff/hire name

# DNA attributes — all floats 0-100
@export var dna_story: float = 0.0
@export var dna_direction: float = 0.0
@export var dna_acting: float = 0.0
@export var dna_music: float = 0.0
@export var dna_visuals: float = 0.0
@export var dna_pacing: float = 0.0
@export var dna_originality: float = 0.0

# Derived DNA composites
@export var dna_mass_appeal: float = 0.0
@export var dna_critical_appeal: float = 0.0

# Lifecycle: in_production -> ready -> released
@export var status: String = "in_production"
