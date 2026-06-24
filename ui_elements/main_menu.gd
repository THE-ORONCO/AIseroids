extends Control

const SPACE: PackedScene = preload("uid://cujdj2kfjxl54")

@onready var play_solo_button: Button = %PlaySoloButton
@onready var policy_editor_button: Button = %PolicyEditorButton
@onready var close_button: Button = %CloseButton
@onready var onnx_file_db: OnnxFileDB = %OnnxFileDB
@onready var main_screen: MarginContainer = %MainScreen
@onready var policy_editor_screen: MarginContainer = %PolicyEditorScreen
@onready var footer: MarginContainer = %Footer

@onready var default_model_dir := DirAccess.open("models")


func _ready() -> void:
	onnx_file_db.scan_dir(default_model_dir)

	policy_editor_screen.hide()
	
	policy_editor_button.pressed.connect(toggle_policy_editor_ui)
	close_button.pressed.connect(toggle_policy_editor_ui)	
	
	play_solo_button.pressed.connect(func(): get_tree().change_scene_to_packed(SPACE))
		



func toggle_policy_editor_ui() -> void:
	main_screen.visible =  policy_editor_screen.visible
	footer.visible = policy_editor_screen.visible
	policy_editor_screen.visible = not policy_editor_screen.visible
	
