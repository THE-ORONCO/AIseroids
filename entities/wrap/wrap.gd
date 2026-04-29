class_name Wrap
extends Area2D

@export var fit_to_screen: bool = true
@export var fallback_size: Vector2 = Vector2(500., 500.)

@onready var top: CollisionShape2D = %top
@onready var left: CollisionShape2D = %left
@onready var right: CollisionShape2D = %right
@onready var bottom: CollisionShape2D = %bottom

var extent: Vector2

var _wrap_candidates: Dictionary[RigidBody2D,RigidBody2D] = {}

# TODO maybe just use these to move all objects automagically 
# - a Wrapping group could then be used to mark all objects that could wrap
# - each object would get a buffer the size of its collision
# - the velocity direction of the object would be the deciding factor on if the shape teleports or not 
func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	if fit_to_screen:
		get_viewport().size_changed.connect(move_boundaries_to_screen_border)
		move_boundaries_to_screen_border.call_deferred()
	else:
		extent = fallback_size
		update_border_positions(extent)
	
func move_boundaries_to_screen_border() -> void:
	extent = self.get_viewport_rect().size
	update_border_positions(extent)

func update_border_positions(extent: Vector2) -> void:
	top.position.x = extent.x / 2
	
	left.position.y = extent.y / 2
	
	bottom.position.x = extent.x / 2
	bottom.position.y = extent.y
	
	right.position.x = extent.x
	right.position.y = extent.y / 2
#
#func wrap_ray(target_pos: Vector2, direction: Vector2, margin: Vector2) -> Vector2:
	#var wrap_delta: Vector2 = Vector2.ZERO
	#if direction.x < 0.:
		#print("left")
		#if target_pos.x + margin <= self.global_position.x:
			#print("\twrap")
			#wrap_delta.x += extent.x
	#elif direction.x > 0.:
		#print("right")
		#if target_pos.x + margin >= self.global_position.x + extent.x:
			#print("\twrap")
			#wrap_delta.x -= extent.x
#
	#if direction.y < 0.:
		#print("up")
	#elif direction.y > 0:
		## down collider
		#print("down")
	#
	#return target_pos + wrap_delta



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
		var left_entity_bound := pos.x + margin_left
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

func _physics_process(delta: float) -> void:
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
