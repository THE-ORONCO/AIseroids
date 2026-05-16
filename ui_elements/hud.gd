class_name Hud
extends MarginContainer

@export var wrap_space: Wrap

@onready var score_label: Label = %ScoreLabel

func _ready() -> void:
	resize_to_wrap()
	wrap_space.size_changed.connect(resize_to_wrap)
	show_score(0)

func show_score(score: int) -> void:
	score_label.text = "Score: %05d" % score

func resize_to_wrap() -> void:
	self.custom_minimum_size = wrap_space.extent
