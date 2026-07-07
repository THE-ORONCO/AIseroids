class_name ExitHandler
extends Node

signal exiting

func signal_exiting():
	exiting.emit()
	await get_tree().create_timer(.5).timeout
