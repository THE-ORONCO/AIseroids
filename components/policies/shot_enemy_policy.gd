class_name ShotEnemyPolicy
extends RewardPolicy

@export var reward: float = 1.

func evaluate_unmodified(context: Dictionary) -> float:
	assert(context.has("controller"), "Missing required context key: controller")
	var controller: ShipController = context["controller"]
	if controller.shot_enemy:
		return reward
	return 0.
