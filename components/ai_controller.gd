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
		float(self.current_shots) / float(self.shots_max),
		self.time_till_reload / self.reload_time,
		self.shot_cooldown / self.cooldown_time,
		self.current_speed / self.max_velocity
	]
