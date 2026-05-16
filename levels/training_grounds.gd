extends Node2D

const WRAP = preload("uid://dq5kaans1s87n")
const SHIP = preload("uid://cunuddi5si8ua")
const TRAINING_SPACE = preload("uid://6k24nqcbijxg")

@export_range(1, 16) var x: int = 4
@export_range(1, 9) var y: int = 3 
@export_range(1, 500) var padding: int = 150
@onready var camera: Camera2D = $Camera


func _ready() -> void:

	
	for dx in range(x):
		for dy in range(y):
			var space: Space = TRAINING_SPACE.instantiate()
			self.add_child(space)
			
			var playfield_width := space.wrap.extent.x
			var playfield_height := space.wrap.extent.y
			
			var xi := padding + (playfield_width + padding) * dx
			var yi := padding + (playfield_height + padding) * dy
			var pos: Vector2 = Vector2(xi,yi)
			
			space.global_position = pos + Vector2(playfield_width / 2.0, playfield_height / 2.0)
			
			# TODO auto generate the scenes if possible
			#var wrap: Wrap = WRAP.instantiate()
			#wrap.global_position = pos
			#wrap.fallback_size = Vector2(playfield_width, playfield_height)
			#wrap.fit_to_screen = false
			#
			#self.add_child(wrap)
			#
			#
			#var ship: Ship = SHIP.instantiate()
			#ship.global_position = pos + Vector2(playfield_width / 2.0, playfield_height / 2.0)
			#self.add_child.call_deferred(ship)
			#
