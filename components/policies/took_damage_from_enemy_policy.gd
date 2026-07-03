class_name TookDamageFromEnemyPolicy
extends RewardPolicy


@export var reward: float = -1.


func evaluate_unmodified(context: Dictionary) -> float:
	assert(context.has("controller"), "Missing required context key: controller")
	assert(context.has("health_delta"), "Missing required context key: health_delta")
	var controller: ShipController = context["controller"]
	var health_delta = context["health_delta"]
	if health_delta < 0 and controller.last_damage_was_enemy_damage:
		return health_delta
	return 0.
