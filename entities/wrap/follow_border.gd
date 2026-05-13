extends CollisionShape2D


@export var to_follow: CollisionShape2D
@export var offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	if to_follow:
		self.global_position = to_follow.global_position + offset


func _physics_process(delta: float) -> void:
	if to_follow:
		self.global_position = to_follow.global_position + offset
