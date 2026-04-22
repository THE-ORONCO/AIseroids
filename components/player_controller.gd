class_name PlayerController
extends ShipController


func thrust() -> float:
	return Input.get_action_strength("thrust")
	
func turn() -> float:
	return Input.get_axis("rotate_left", "rotate_right")

func shoot() -> bool:
	return Input.is_action_just_pressed("fire")
