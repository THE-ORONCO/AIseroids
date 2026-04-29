class_name AiController
extends ShipController

func update_inputs(
	thrust: float,
	turn: float,
	shoot: bool,
) -> void:
	self.thrust = thrust
	self.turn = turn
	self.shoot = shoot
