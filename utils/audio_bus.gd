class_name AudioBus
extends Node

@onready var explode_sound: AudioStreamPlayer = $Explode
@onready var hit_sound: AudioStreamPlayer = $Hit

func explode() -> void:
	explode_sound.pitch_scale = randf_range(0.97,1.03)
	explode_sound.play()
	
func hit() -> void:
	hit_sound.pitch_scale = randf_range(0.97,1.03)
	hit_sound.play()
