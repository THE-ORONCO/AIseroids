class_name TooFastPolicy
extends RewardPolicy


@export var reward: float = -1.0
@export var speed_bump: float = 300.0
@export var speed_rolling_size: float = 30.0
@export var speed_reduce: float = 5.0
@export var max_speed_for_scale: float = 1000.0
@export var min_scale: float = 0.2
@export var max_scale: float = 1.0

var _speed_average: float = 0.0


func evaluate_unmodified(context: Dictionary) -> float:
	assert(context.has("controller"), "Missing required context key: controller")
	var controller = context["controller"]
	var curr_speed = controller.current_speed
	_speed_average = _speed_average * ((speed_rolling_size - 1.0) / speed_rolling_size) + curr_speed / speed_rolling_size

	if _speed_average > speed_bump:
		var reward_scale = remap(curr_speed, speed_bump, max_speed_for_scale, min_scale, max_scale)
		_speed_average = 0.0
		return reward * reward_scale
	_speed_average = move_toward(_speed_average, 0.0, speed_reduce) # slowly reduce the average to allow for some speed variations
	return 0.0

func reset() -> void:
	_speed_average = 0.0
