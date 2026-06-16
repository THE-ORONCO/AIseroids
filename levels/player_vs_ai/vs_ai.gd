extends Node2D

#@onready var ai_ship: Ship = %AiShip
#@onready var respawn_timer: Timer = %RespawnTimer
#@onready var ship_brain: ShipBrain2D = %ShipBrain
#
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#ai_ship.health_reached_zero.connect(handle_ai_destruction)
#
#func handle_ai_destruction() -> void:
	#self.remove_child(ai_ship)
	#respawn_timer.start()
	#self.add_child(ai_ship)
