class_name Wrap
extends Area2D

signal size_changed

@export var fit_to_screen: bool = true
@export var fallback_size: Vector2 = Vector2(500., 500.)

@export_range(1., 50.) var ship_size := 30.:
	set(val):
		ray_wrap.ship_size = val
		ship_size = ship_size

@onready var topr: CollisionShape2D = %topr
@onready var bottomr: CollisionShape2D = %bottomr
@onready var leftr: CollisionShape2D = %leftr
@onready var rightr: CollisionShape2D = %rightr
@onready var ray_wrap: RayWrap = %RayWrap

@onready var topl: CollisionShape2D = %topl
@onready var bottoml: CollisionShape2D = %bottoml
@onready var leftl: CollisionShape2D = %leftl
@onready var rightl: CollisionShape2D = %rightl


var extent: Vector2:
	set(val):
		ray_wrap.extent = val
		extent = val

var _wrap_candidates: Dictionary[RigidBody2D,RigidBody2D] = {}

# TODO maybe just use these to move all objects automagically 
# - a Wrapping group could then be used to mark all objects that could wrap
# - each object would get a buffer the size of its collision
# - the velocity direction of the object would be the deciding factor on if the shape teleports or not 
func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	if fit_to_screen:
		get_viewport().size_changed.connect(move_boundaries_to_screen_border)
		get_viewport().size_changed.connect(size_changed.emit)
		move_boundaries_to_screen_border.call_deferred()
	else:
		extent = fallback_size
		update_border_positions()
		
	ray_wrap.extent = extent
	ray_wrap.ship_size = ship_size
	
func move_boundaries_to_screen_border() -> void:
	extent = self.get_viewport_rect().size
	update_border_positions()

func update_border_positions() -> void:
	_resize_area_blocks()
	_resize_lines()

func _resize_area_blocks() -> void:
	const extra_padding := 100. # to prevent the escape of asteroids and ships that get pushed arround weirdly 
	const extra_offset := extra_padding / 2.

	var half_ship_size := ship_size / 2.
	var bar_thickness := ship_size + extra_padding
	var bar_y_offset :=  bar_thickness / 2.
	var bar_x_offset := bar_thickness / 2.
	var vbar_length:= extent.y + bar_thickness
	var hbar_length := extent.x + bar_thickness
	
	topr.position.x = (extent.x - bar_thickness) / 2.
	topr.position.y = 0.0 - bar_y_offset
	topr.shape.size.x = hbar_length
	topr.shape.size.y = bar_thickness
	
	bottomr.position.x = (extent.x + bar_thickness) / 2.
	bottomr.position.y = extent.y + bar_y_offset
	bottomr.shape.size.x = hbar_length
	bottomr.shape.size.y = bar_thickness
	
	leftr.position.x = 0.0 - bar_x_offset
	leftr.position.y = (extent.y + bar_thickness) / 2.
	leftr.shape.size.x = bar_thickness 
	leftr.shape.size.y = vbar_length
	
	rightr.position.x = extent.x + bar_x_offset
	rightr.position.y = (extent.y - bar_thickness) / 2.
	rightr.shape.size.x = bar_thickness
	rightr.shape.size.y = vbar_length


func _resize_lines() -> void:
	var toplft := Vector2(-ship_size, -ship_size)
	var toprgt := Vector2(extent.x + ship_size, -ship_size)
	var botlft := Vector2(-ship_size, extent.y + ship_size)
	var botrgt := Vector2(extent.x + ship_size, extent.y + ship_size)
	
	topl.shape.a = toplft
	topl.shape.b = toprgt
	
	bottoml.shape.a = botlft
	bottoml.shape.b = botrgt
	
	leftl.shape.a = toplft
	leftl.shape.b = botlft
	
	rightl.shape.a = toprgt
	rightl.shape.b = botrgt


func wrap_delta_aabb(pos: Vector2, direction: Vector2, aabb: Rect2) -> Vector2:
	var wrap_delta: Vector2 = Vector2.ZERO
	var margin_left: float = absf(aabb.position.x)
	var margin_right: float = absf(aabb.end.x)
	var margin_top: float = absf(aabb.position.y)
	var margin_bottom: float = absf(aabb.end.y)
	var entity_width: float = aabb.size.x
	var entity_height: float = aabb.size.y

	if direction.x < 0.: # moving left
		var left_wrap_bound := self.global_position.x
		var right_entity_bound := pos.x + margin_right
		if right_entity_bound <= left_wrap_bound:
			wrap_delta.x += extent.x + entity_width
	elif direction.x > 0.: # moving right
		var right_wrap_bound := self.global_position.x + extent.x
		var left_entity_bound := pos.x - margin_left
		if left_entity_bound >= right_wrap_bound:
			wrap_delta.x -= extent.x + entity_width

	if direction.y < 0.: # moving up
		var top_wrap_bound := self.global_position.y
		var bottom_entity_bound := pos.y + margin_bottom
		if bottom_entity_bound <= top_wrap_bound:
			wrap_delta.y += extent.y + entity_height
	elif direction.y > 0: # moving down
		var bottom_wrap_bound := self.global_position.y + extent.y
		var top_entity_bound := pos.y - margin_top
		if top_entity_bound >= bottom_wrap_bound:
			wrap_delta.y -= extent.y + entity_height
	
	return wrap_delta


func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		_wrap_candidates.set(body, body)

func _on_body_exited(body: Node2D) -> void:
	if body is RigidBody2D:
		_wrap_candidates.erase(body)

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint(): return 
	
	for body: RigidBody2D in self.get_overlapping_bodies():
		if body is not RigidBody2D:
			continue
		var r: RigidBody2D = body
		var collision_shapes := r.get_children().filter(func(c): return c is CollisionShape2D)
		if collision_shapes.size() > 0:
			var col: CollisionShape2D = collision_shapes[0]
			var direction := r.linear_velocity.normalized()
			var wrap_delta := wrap_delta_aabb(body.global_position, direction, col.shape.get_rect())
			body.global_position += wrap_delta
