class_name AiDemoButton
extends Button

func when_pressed_change_to(scene: PackedScene, onnx_model_path: String) -> void:
	self.pressed.connect(func():
		var space = scene.instantiate()
		space.onnx_model_path = onnx_model_path
		get_tree().change_scene_to_node(space)
		)
