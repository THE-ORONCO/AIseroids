extends RigidBody2D

var _screen_size: Vector2:
	get: return self.get_viewport_rect().size

func _physics_process(delta: float) -> void:
	self.global_position = MoveUtils.screen_wrap(self.global_position, _screen_size)
