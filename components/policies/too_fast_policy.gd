class_name TooFastPolicy
extends RewardPolicy


@export var reward: float = -1.0
@export var speed_bump: float = 300.0
@export var speed_rolling_size: float = 30.0
@export var speed_reduce: float = 5.0
@export var max_speed_for_scale: float = 1000.0
@export var min_scale: float = 0.2
@export var max_scale: float = 1.0

const speed_avg := "TooFastPolicy.speed_average"


func evaluate_unmodified(context: Dictionary) -> float:
	if !context.has(speed_avg): context[speed_avg] = 0.
	assert(context.has("controller"), "Missing required context key: controller")
	var controller = context["controller"]
	var curr_speed = controller.current_speed
	context[speed_avg] = context[speed_avg] * ((speed_rolling_size - 1.0) / speed_rolling_size) + curr_speed / speed_rolling_size

	if context[speed_avg] > speed_bump:
		var reward_scale = remap(curr_speed, speed_bump, max_speed_for_scale, min_scale, max_scale)
		context[speed_avg] = 0.0
		return reward * reward_scale
	context[speed_avg] = move_toward(context[speed_avg], 0.0, speed_reduce) # slowly reduce the average to allow for some speed variations
	return 0.0
