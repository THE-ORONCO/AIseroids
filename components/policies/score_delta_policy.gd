class_name ScoreDeltaPolicy
extends RewardPolicy


@export var bug_detection_amount = 5
var bug_assert_message = "Score changed by an unreasonable amount in a few physics ticks"

func _init():
	policy_name = "score_delta"

func evaluate_unmodified(context: Dictionary) -> float:
	assert(context.has("score_delta"), "Missing required context key: score_delta")
	var score_delta: float = context["score_delta"]
	assert(abs(score_delta) < bug_detection_amount, bug_assert_message)
	return score_delta
