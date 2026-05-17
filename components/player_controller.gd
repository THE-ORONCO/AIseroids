class_name PlayerController
extends ShipController

func  _physics_process(_delta: float) -> void:
	thrust = Input.get_action_strength("thrust")
	turn = Input.get_axis("rotate_left", "rotate_right")
	shoot = Input.is_action_pressed("fire")
