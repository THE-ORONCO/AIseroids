extends Control

enum FileDialogMode {
	LOAD_POLICY_PRESET,
	LOAD_PREVIOUS,
	EXPORT_POLICY_PRESET,
}

const SPACE: PackedScene = preload("uid://cujdj2kfjxl54")

@onready var play_solo_button: Button = %PlaySoloButton
@onready var policy_editor_button: Button = %PolicyEditorButton
@onready var close_button: Button = %CloseButton
@onready var load_button: Button = %LoadButton
@onready var load_previous_button: Button = %LoadPreviousButton
@onready var export_button: Button = %ExportButton
@onready var x_input: LineEdit = %XInput
@onready var y_input: LineEdit = %YInput
@onready var number_of_agents: Label = %NumberOfAgents
@onready var onnx_file_db: OnnxFileDB = %OnnxFileDB
@onready var main_screen: MarginContainer = %MainScreen
@onready var policy_editor_screen: MarginContainer = %PolicyEditorScreen
@onready var footer: MarginContainer = %Footer
@onready var file_dialog: FileDialog = %FileDialog
@onready var error_notification: AcceptDialog = %ErrorNotification
@onready var policy_editor_ui: PolicyEditorUI = %PolicyEditorUI

@onready var default_model_dir := DirAccess.open("models")

var selected_file_dialogue_mode: FileDialogMode

func _ready() -> void:
	onnx_file_db.scan_dir(default_model_dir)

	policy_editor_screen.hide()
	x_input.text_changed.connect(_update_agent_count)
	y_input.text_changed.connect(_update_agent_count)
	
	start_training.pressed.connect(func():
		var training_grounds: TrainingGrounds = TRAINING_GROUNDS.instantiate()
		var field_size := _get_field_size()
		var training_start_time := Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
		training_start_time = training_start_time.substr(0, training_start_time.length() - 3)
		var policy_log_save_path := PolicyManager.FOLDER_PATHS.logs + training_start_time + ".tres"
		training_grounds.x = field_size.x
		training_grounds.y = field_size.y
		PolicyManager.save_loaded_policy_collection(policy_log_save_path)
		get_tree().change_scene_to_node(training_grounds)
		)
	
	policy_editor_button.pressed.connect(toggle_policy_editor_ui)
	close_button.pressed.connect(toggle_policy_editor_ui)
	load_button.pressed.connect(open_file_dialogue.bind(FileDialogMode.LOAD_POLICY_PRESET))
	load_previous_button.pressed.connect(open_file_dialogue.bind(FileDialogMode.LOAD_PREVIOUS))
	export_button.pressed.connect(open_file_dialogue.bind(FileDialogMode.EXPORT_POLICY_PRESET))
	file_dialog.file_selected.connect(_on_file_selected)
	
	play_solo_button.pressed.connect(func(): get_tree().change_scene_to_packed(SPACE))
	
	onnx_file_db.scan_dir(default_model_dir)


func _get_field_size() -> Vector2i:
	return Vector2i(\
		int(x_input.text) if x_input.text else 0,\
		int(y_input.text) if y_input.text else 0,\
	)


func _update_agent_count(_input) -> void:
	var field_size := _get_field_size()
	number_of_agents.text = "=  %d Agents" % (field_size.x * field_size.y)


func _on_file_selected(file_path: String) -> void:
	match selected_file_dialogue_mode:
		FileDialogMode.LOAD_POLICY_PRESET:
			var error = PolicyManager.load_from_file(file_path)
			if error == OK:
				policy_editor_ui.update()
				return
			error_notification.dialog_text = "The selected file isn't a policy collection. Try another one!"
			error_notification.show()
		FileDialogMode.LOAD_PREVIOUS:
			var error = PolicyManager.load_from_file(file_path)
			if error == OK:
				policy_editor_ui.update()
				return
			error_notification.dialog_text = "The selected file isn't a policy collection. Try another one!"
			error_notification.show()
		FileDialogMode.EXPORT_POLICY_PRESET:
			PolicyManager.save_loaded_policy_collection(file_path)


func open_file_dialogue(mode: FileDialogMode) -> void:
	match mode:
		FileDialogMode.LOAD_POLICY_PRESET:
			file_dialog.root_subfolder = PolicyManager.FOLDER_PATHS.presets
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			selected_file_dialogue_mode = mode
		FileDialogMode.LOAD_PREVIOUS:
			file_dialog.root_subfolder = PolicyManager.FOLDER_PATHS.logs
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			selected_file_dialogue_mode = mode
		FileDialogMode.EXPORT_POLICY_PRESET:
			file_dialog.root_subfolder = PolicyManager.FOLDER_PATHS.presets
			file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			selected_file_dialogue_mode = mode
		_:
			push_error("Tried to open file dialog with an invalid mode")
			return
	file_dialog.show()


func toggle_policy_editor_ui() -> void:
	main_screen.visible =  policy_editor_screen.visible
	footer.visible = policy_editor_screen.visible
	policy_editor_screen.visible = not policy_editor_screen.visible
	
