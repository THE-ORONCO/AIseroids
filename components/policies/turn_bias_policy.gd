class_name TurnBiasPolicy
extends RewardPolicy
## TODO make this strong in the beginning to prevent excessive spinning and remove later on to allow for better controll

@export var turn_bias_rolling_size: float = 50.0
@export var max_turn_bias: float = 0.2
@export var turn_bias_reduce: float = 0.01
@export var max_turn_bias_reward: float = 0.1

const turn_avg := "TurnBiasPolicy.turn_average"

func evaluate_unmodified(context: Dictionary) -> float:
	if !context.has(turn_avg): context[turn_avg] = 0.
	assert(context.has("controller"), "Missing required context key: controller")
	var controller = context["controller"]
	var turn = controller.turn
	context[turn_avg] = context[turn_avg] * ((turn_bias_rolling_size - 1.0) / turn_bias_rolling_size) + turn / turn_bias_rolling_size
	if abs(context[turn_avg]) > max_turn_bias:
		var reward = -clamp(abs(context[turn_avg]), 0.0, 1.0) * max_turn_bias_reward
		context[turn_avg] = move_toward(context[turn_avg], 0.0, turn_bias_reduce)
		return reward
	context[turn_avg] = move_toward(context[turn_avg], 0.0, turn_bias_reduce) # slowly reduce the average to allow for permanent turning
	return 0.0
