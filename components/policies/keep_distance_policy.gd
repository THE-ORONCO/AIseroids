class_name KeepDistancePolicy
extends RewardPolicy


const REWARD: float = -1.

func _init():
	policy_name = "keep_distance_to_asteroids"

func evaluate_unmodified(context: Dictionary) -> float:
	assert(context.has("sensor"), "Missing required context key: sensor")
	var sensor = context["sensor"]
	if sensor.ray_sensor.asteroid_is_close:
		return REWARD
	return 0.
