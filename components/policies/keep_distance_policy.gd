class_name KeepDistancePolicy
extends RewardPolicy


@export var reward: float = -1.


func evaluate_unmodified(context: Dictionary) -> float:
	assert(context.has("sensor"), "Missing required context key: sensor")
	var sensor = context["sensor"]
	if sensor.ray_sensor.asteroid_is_close:
		return reward
	return 0.
