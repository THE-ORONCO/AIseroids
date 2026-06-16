@tool
class_name AiSelector 
extends Control

@export var db: OnnxFileDB:
	set(val):
		update_configuration_warnings()
		db = val
		if db && ai_options:
			_update_options(db.files)

@onready var ai_options: OptionButton = %AiOptions
@onready var file_dialog: FileDialog = %FileDialog
@onready var file_dialogue_button: Button = %FileDialogueButton

@onready var _default_model_dir := DirAccess.open("models").get_current_dir()

var selected: String:
	get: 
		var index := ai_options.selected
		var path: String = ai_options.get_item_metadata(index)
		return path


func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	file_dialogue_button.pressed.connect(file_dialog.popup)
	file_dialog.file_selected.connect(func(path):
		db.add_custom(path)
		_focus_item_with_path.call_deferred(path)
		)
	file_dialog.current_dir = "./models"

	db.new_file_ingested.connect(func(): 
		_update_options(db.files))
	
	_update_options(db.files)

func _focus_item_with_path(path: String) -> void:
	for i in ai_options.item_count:
		var item_path: String = ai_options.get_item_metadata(i)
		if path == item_path:
			ai_options.select(i)
			return


func _update_options(files: Array[String]) -> void:
	ai_options.clear()
	
	for i in files.size():
		var file := files[i]
		_add_item(file, i)
	
	if !files.is_empty():
		ai_options.select(0)

func _add_item(path: String, id: int) -> int:
	var short_name := path.replace(_default_model_dir + "/", "")
	ai_options.add_item(short_name, id)
	var idx := ai_options.get_item_index(id)
	ai_options.set_item_metadata(idx, path)
	return idx

func _get_configuration_warnings() -> PackedStringArray:
	var warn: PackedStringArray = []
	if !db: warn.append("The selector does not know which files to use without a db!")
	return warn
