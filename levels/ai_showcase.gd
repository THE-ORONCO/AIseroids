class_name AiShowcase
extends Node2D

@export var onnx_model_path: String

@onready var space: Space = %Space
@onready var sync: Node = %Sync

func _ready() -> void:
	space.onnx_model_path = onnx_model_path
	sync.onnx_model_path = onnx_model_path
