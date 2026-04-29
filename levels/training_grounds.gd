extends Node2D

const WRAP = preload("uid://dq5kaans1s87n")

@export_range(1, 16) var x: int = 4
@export_range(1, 9) var y: int = 3 
@export_range(1, 200) var padding: int = 150
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
			
			var wrap: Wrap = WRAP.instantiate()
			wrap.global_position = pos
			wrap.fallback_size = Vector2(playfield_width, playfield_height)
			wrap.fit_to_screen = false
			
			self.add_child(wrap)
			
