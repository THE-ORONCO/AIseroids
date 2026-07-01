class_name WaveClearProgressPolicy
extends RewardPolicy


@export var progress_multiplier: float = 0.05
@export var early_progress_bonus: float = 2.0
@export var early_progress_window_msec: int = 60000
@export var min_multiplier: float = 0.0
@export var max_multiplier: float = 100.0

const ast_dest := "WaveClearProgressPolicy.asteroids_destroyed"

func evaluate_unmodified(context: Dictionary) -> float:
	if !context.has(ast_dest): context[ast_dest] = 0.
	assert(context.has("score_delta"), "Missing required context key: score_delta")
	assert(context.has("last_reset_time"), "Missing required context key: last_reset_time")
	var now = context.get("now", Time.get_ticks_msec())
	var score_delta = context["score_delta"]
	if score_delta > 0:
		context[ast_dest] += score_delta
		var reward_scale = progress_multiplier
		var last_reset = context["last_reset_time"]
		if abs(now - last_reset) < early_progress_window_msec:
			reward_scale *= early_progress_bonus
		reward_scale = clamp(reward_scale, min_multiplier, max_multiplier)
		return context[ast_dest] * reward_scale
	return 0.0
