class_name ReleaseData
extends Resource

@export var movie_data: Resource
@export var distributor: Resource

@export var marketing_spend: int = 0
@export var marketing_tier: String = "None"
@export var buzz: float = 0.0  # 0-100

@export var release_week: int = 0
@export var current_week_in_release: int = 0
@export var screens: int = 0

@export var weekly_box_office: Array = []
@export var weekly_audience: Array = []

@export var total_box_office: int = 0
@export var total_audience: int = 0

@export var critic_rating: float = 0.0  # 0.0 to 5.0
@export var audience_rating: float = 0.0  # 0.0 to 5.0
@export var word_of_mouth: float = 50.0  # 0-100

@export var status: String = "setup"  # setup, released, completed
@export var weeks_screened: int = 0
@export var result_classification: String = ""
