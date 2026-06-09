extends Control

@export var watched: Ship

@onready var speed_label: Label = %SpeedLabel

func _physics_process(_delta: float) -> void:
	if watched:
		speed_label.text = "%03.1f" % watched.linear_velocity.length()
