class_name HealthDeltaPolicy
extends RewardPolicy


@export var bug_detecion_amount: int = 5
var bug_assert_message: String = "Health changed by an unreasonable amount in a few physics ticks"

func _init():
	policy_name = "health_delta"

func evaluate_unmodified(context: Dictionary) -> float:
	assert(context.has("health_delta"), "Missing required context key: health_delta")
	var health_delta = context["health_delta"]
	assert(abs(health_delta) < bug_detecion_amount, bug_assert_message)
	return health_delta
