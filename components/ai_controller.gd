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

func get_ship_state() -> Array:
	return [
		self.shots_max,
		self.current_shots,
		self.time_till_reload,
		self.shot_cooldown,
	]
