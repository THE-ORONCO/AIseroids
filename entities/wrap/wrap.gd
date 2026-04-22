@tool
extends Area2D

@onready var top: CollisionShape2D = %top
@onready var left: CollisionShape2D = %left
@onready var right: CollisionShape2D = %right
@onready var bottom: CollisionShape2D = %bottom

var _screen_size: Vector2

func _ready() -> void:
	_screen_size = self.get_viewport_rect().size
	top.position.x = _screen_size.x / 2
	
	left.position.y = _screen_size.y / 2
	
	bottom.position.x = _screen_size.x / 2
	bottom.position.y = _screen_size.y
	
	right.position.x = _screen_size.x
	right.position.y = _screen_size.y / 2
