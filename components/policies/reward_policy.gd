@abstract
class_name RewardPolicy
extends Resource

@export var policy_name: String = ""
@export var enabled: bool = true
@export_range(0., 1., .1, "or_greater") var weight: float = 1.0
@export_range(0., 1., .1, "or_greater") var scale: float = 1.0


func evaluate(context: Dictionary) -> float:
	assert(context != null, "Context is null. Cannot evaluate!")
	var unmodified_reward = evaluate_unmodified(context)
	return unmodified_reward * scale * weight

@abstract
func evaluate_unmodified(context: Dictionary) -> float

# Default no-op; override in policies that need it
func reset() -> void:
	pass
