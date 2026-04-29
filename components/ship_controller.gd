@abstract
class_name ShipController 
extends Node

var sensor: ISensor2D

var thrust: float = 0.0:
	set(val): thrust = clampf(val, 0., 1.)
var turn: float = 0.0:
	set(val): turn = clampf(val, -1., 1.)
var shoot: bool = false


func get_sensor_info() -> Array:
	if sensor != null:
		return sensor.get_observation()
	return []
