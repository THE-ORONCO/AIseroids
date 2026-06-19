class_name EmptyMagPolicy
extends RewardPolicy

@export var reward: float = -1.

func _init():
	policy_name = "shoot_with_no_shots"

func evaluate_unmodified(context: Dictionary) -> float:
	assert(context.has("controller"), "Missing required context key: controller")
	var controller = context["controller"]
	if controller.current_shots == 0 and bool(controller.shoot):
		return reward
	return 0.
