class_name AiController
extends ShipController

func update_inputs(
	thrust_in: float,
	turn_in: float,
	shoot_in: bool,
) -> void:
	self.thrust = thrust_in
	self.turn = turn_in
	self.shoot = shoot_in

func get_ship_state() -> Array:
	return [
		self.shots_max,
		self.current_shots,
		self.time_till_reload,
		self.shot_cooldown,
	]
