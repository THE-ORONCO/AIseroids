@abstract
class_name ShipController 
extends Node

var sensor: ISensor2D

var thrust: float = 0.0:
	set(val): thrust = clampf(val, 0., 1.)
var turn: float = 0.0:
	set(val): turn = clampf(val, -1., 1.)
var shoot: bool = false

var health: int
var health_max: int = 5
var score: int = 0
var shots_max: int = 0
var current_shots: int = 0
var time_till_reload: float = 0.
var shot_cooldown: float = 0.
var currents_speed: float = 0.

func _init() -> void:
	health = health_max

func get_sensor_info() -> Array:
	if sensor != null:
		return sensor.get_observation()
	return []
