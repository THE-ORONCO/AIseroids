extends Node

signal asteroid_destroyed(points_earned: int)

func signal_asteroid_destoryed(size: float):
	asteroid_destroyed.emit(1)
