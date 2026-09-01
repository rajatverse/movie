class_name DistributorData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var reach: float = 1.0  # multiplier for demand/audience
@export var screen_access: int = 100  # maximum screens they can secure
@export var popularity: float = 50.0  # 0-100, affects initial buzz
@export var revenue_share: float = 0.5  # 0.0 - 1.0 (e.g. 0.5 = they keep 50% of BO)
@export var min_reputation: int = 0
