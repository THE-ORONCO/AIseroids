class_name ScoreLabel
extends Label


var score_prefix: String = "Score: "


func  _ready() -> void:
	text = score_prefix + "0"
	ScoreKeeper.score_changed.connect(
		func(new_score): text = score_prefix + str(new_score)
	)
