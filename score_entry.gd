class_name ScoreEntry
extends HBoxContainer


@onready var name_label: Label = %NameLabel
@onready var score_label: Label = %ScoreLabel


func update(entry_name: String, score: int) -> void:
	name_label.text = entry_name
	score_label.text = str(score)
