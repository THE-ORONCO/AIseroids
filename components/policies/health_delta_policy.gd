class_name HealthDeltaPolicy
extends RewardPolicy


func evaluate_unmodified(context: Dictionary) -> float:
	assert(context.has("health_delta"), "Missing required context key: health_delta")
	var health_delta = context["health_delta"]
	return health_delta
