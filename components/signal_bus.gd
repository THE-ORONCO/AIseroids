class_name SignalBus 
extends Node

signal asteroid_destroyed(team: S_Team, points_earned: int)

func signal_asteroid_destoryed(team: S_Team):
	asteroid_destroyed.emit(team, 1)
