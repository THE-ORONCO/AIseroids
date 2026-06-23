class_name ScoreDeltaPolicy
extends RewardPolicy


func evaluate_unmodified(context: Dictionary) -> float:
	assert(context.has("score_delta"), "Missing required context key: score_delta")
	var score_delta: float = context["score_delta"]
	assert(abs(score_delta) < 5, "Score changed by an unreasonable amount in a few physics ticks")
	return score_delta
