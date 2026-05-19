class_name SignalBus 
extends Node

signal asteroid_destroyed(points_earned: int)

func signal_asteroid_destoryed(_size: float):
	asteroid_destroyed.emit(1)
