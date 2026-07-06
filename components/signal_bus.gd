class_name SignalBus 
extends Node

signal asteroid_destroyed(team: S_Team, points_earned: int)
signal shot_hit_ship(shot: Shot, ship: Ship)

func signal_asteroid_destoryed(team: S_Team) -> void:
	asteroid_destroyed.emit(team, 1)

func signal_shot_hit_ship(shot: Shot, ship: Ship) -> void:
	shot_hit_ship.emit(shot, ship)
