class_name SelfDamagePolicy
extends RewardPolicy


func evaluate_unmodified(context: Dictionary) -> float:
	assert(context.has("controller"), "Missing required context key: controller")
	assert(context.has("health_delta"), "Missing required context key: health_delta")
	var controller = context["controller"]
	var health_delta = context["health_delta"]
	if health_delta < 0 and controller.shot_self:
		return health_delta
	return 0.
