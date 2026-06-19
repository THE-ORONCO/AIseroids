class_name S_Muzzle
extends Resource

@export_range(1., 100.) var max_shots: int = 5
@export_range(0.01, 2.) var cooldown: float = .3
@export_range(0.1, 3.) var reload_time: float = 1.
@export var shot: S_Shot = S_Shot.new()
