class_name PlayerController
extends ShipController


func thrust() -> float:
	if Input.is_action_pressed("thrust"):
		return 1.
	return 0.
	
func turn() -> float:
	return Input.get_axis("rotate_left", "rotate_right")

func shoot() -> bool:
	return Input.is_action_just_pressed("fire")
