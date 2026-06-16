class_name CM_Inference
extends ControlMode

## path to the onnx model used for this ship
@export_global_file("*.onnx") var model_path: String
