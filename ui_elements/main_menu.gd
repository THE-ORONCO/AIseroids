extends Control

enum FileDialogMode {
	LOAD_POLICY_PRESET,
	LOAD_PREVIOUS,
	EXPORT_POLICY_PRESET,
}

const SPACE: PackedScene = preload("uid://cujdj2kfjxl54")
const TRAINING_GROUNDS = preload("uid://baw6jdbx8dn5d")

@onready var training_panel: TrainingPanel = %TrainingPanel
@onready var policy_editor_button: Button = %PolicyEditorButton
@onready var close_button: Button = %CloseButton
@onready var load_button: Button = %LoadButton
@onready var load_previous_button: Button = %LoadPreviousButton
@onready var export_button: Button = %ExportButton
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
	
	policy_editor_button.pressed.connect(toggle_policy_editor_ui)
	close_button.pressed.connect(toggle_policy_editor_ui)
	load_button.pressed.connect(open_file_dialogue.bind(FileDialogMode.LOAD_POLICY_PRESET))
	load_previous_button.pressed.connect(open_file_dialogue.bind(FileDialogMode.LOAD_PREVIOUS))
	export_button.pressed.connect(open_file_dialogue.bind(FileDialogMode.EXPORT_POLICY_PRESET))
	file_dialog.file_selected.connect(_on_file_selected)
		
	onnx_file_db.scan_dir(default_model_dir)

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
	
