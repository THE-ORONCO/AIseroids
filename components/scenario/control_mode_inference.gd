class_name CM_Inference
extends ControlMode

## path to the onnx model used for this ship
@export_global_file("*.onnx") var model_path: String
## The number of physics ticks an action is valid for
@export_range(1, 8, 1, "or_greater") var action_repeat: int = 1
