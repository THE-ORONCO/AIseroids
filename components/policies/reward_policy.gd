@abstract
class_name RewardPolicy
extends Resource


@export var policy_name: String = ""
@export var enabled: bool = true
@export_range(0.00001, 1.0, 0.01, "or_greater", ) var weight: float = 1.0


func _init():
	var script: Script = get_script()
	policy_name = script.get_global_name().to_snake_case()
	assert(policy_name != "", str(script) + " has no class name")

func evaluate(context: Dictionary) -> float:
	assert(context != null, "Context is null. Cannot evaluate!")
	var unmodified_reward = evaluate_unmodified(context)
	return unmodified_reward * weight

@abstract
func evaluate_unmodified(context: Dictionary) -> float

# Default no-op; override in policies that need it
func reset() -> void:
	pass
