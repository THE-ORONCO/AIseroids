@abstract
class_name RewardPolicy
extends Resource


@export var enabled: bool = true
@export var weight: float = 1.0:
	set(value):
		weight = max(0., value)
@export var scale: float = 1.0:
	set(value):
		scale = max(0., value)
@export var policy_name: String = ""


func evaluate(context: Dictionary) -> float:
	assert(context != null, "Context is null. Cannot evaluate!")
	var unmodified_reward = evaluate_unmodified(context)
	return unmodified_reward * scale * weight

@abstract
func evaluate_unmodified(context: Dictionary) -> float

# Default no-op; override in policies that need it
func reset() -> void:
	pass
