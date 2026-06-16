class_name TurnBiasPolicy
extends RewardPolicy
## TODO make this strong in the beginning to prevent excessive spinning and remove later on to allow for better controll

@export var turn_bias_rolling_size: float = 50.0
@export var max_turn_bias: float = 0.2
@export var turn_bias_reduce: float = 0.01
@export var max_turn_bias_reward: float = 0.1

var _turn_average: float = 0.0

func _init():
	policy_name = "turn_bias"

func evaluate_unmodified(context: Dictionary) -> float:
	assert(context.has("controller"), "Missing required context key: controller")
	var controller = context["controller"]
	var turn = controller.turn
	_turn_average = _turn_average * ((turn_bias_rolling_size - 1.0) / turn_bias_rolling_size) + turn / turn_bias_rolling_size
	if abs(_turn_average) > max_turn_bias:
		var penalty = -clamp(abs(_turn_average), 0.0, 1.0) * max_turn_bias_reward
		_turn_average = move_toward(_turn_average, 0.0, turn_bias_reduce)
		return penalty
	_turn_average = move_toward(_turn_average, 0.0, turn_bias_reduce) # slowly reduce the average to allow for permanent turning
	return 0.0

func reset() -> void:
	_turn_average = 0.0
