class_name OnnxFileDB
extends Node

signal new_file_ingested

@onready var onnx_regex := RegEx.create_from_string(".*\\.[oO][nN][nN][xX]$")

var _unique_files: Dictionary[String, String] = {}

var files: Array[String]:
	get: return _unique_files.keys()

func scan_dir(dir: DirAccess, filter: RegEx = onnx_regex, recurse: bool = true) -> void:
	var found := FileUtils.flatten_directory(dir, filter, recurse)
	print("found %d onnx models in %s" % [found.size(), dir.get_current_dir()])
	for file in found:
		_unique_files.set(file, file)
	
	if !found.is_empty():
		new_file_ingested.emit()

func add_custom(path: String) -> void:
	if !_unique_files.has(path):
		_unique_files.set(path, path)
		new_file_ingested.emit()
