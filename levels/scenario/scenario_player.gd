extends Node2D

const SHIP = preload("uid://cunuddi5si8ua")

@onready var space: SpaceMulti = %SpaceMulti

func play_scenario(scenario: Scenario) -> void:
	for ship_blueprint in scenario.ships:
		var mode := ship_blueprint.mode
		var controller: ShipController
		if mode is CM_Inference:
			pass
		elif mode is CM_Training:
			pass
		elif mode is CM_Training:
			pass
		else:					assert(false, "unknown controller mode")

		var ship:Ship = SHIP.instantiate()
		ship.configure(ship_blueprint, controller)
		
	assert(false, "implement")
