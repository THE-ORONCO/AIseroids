extends Node2D

const WRAP = preload("uid://dq5kaans1s87n")
const SHIP = preload("uid://cunuddi5si8ua")
const SPACE = preload("uid://cujdj2kfjxl54")

@export_range(1, 16) var x: int = 4
@export_range(1, 9) var y: int = 3 
@export_range(1, 500) var padding: int = 150
@onready var camera: Camera2D = $Camera


func _ready() -> void:
	var camera_size := camera.get_viewport_rect().size
	var playfield_width := (camera_size.x / camera.zoom.x - (x+1) * padding) / x
	var playfield_height := (camera_size.y  / camera.zoom.y - (y+1) * padding)  / y
	
	for dx in range(x):
		for dy in range(y):
			var xi := padding + (playfield_width + padding) * dx
			var yi := padding + (playfield_height + padding) * dy
			var pos: Vector2 = Vector2(xi,yi)
			
			var space: Node2D = SPACE.instantiate()
			space.global_position = pos + Vector2(playfield_width / 2.0, playfield_height / 2.0)
			self.add_child(space)
			
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
