extends Control

const SPACE: PackedScene = preload("uid://cujdj2kfjxl54")
const TRAINING_GROUNDS: PackedScene = preload("uid://baw6jdbx8dn5d")

@onready var play_solo_button: Button = %PlaySoloButton
@onready var start_training: Button = %StartTraining
@onready var policy_editor_button: Button = %PolicyEditorButton
@onready var close_button: Button = %CloseButton
@onready var x_input: LineEdit = %XInput
@onready var y_input: LineEdit = %YInput
@onready var number_of_agents: Label = %NumberOfAgents
@onready var onnx_file_db: OnnxFileDB = %OnnxFileDB
@onready var main_screen: MarginContainer = %MainScreen
@onready var policy_editor_screen: MarginContainer = %PolicyEditorScreen
@onready var footer: MarginContainer = %Footer

@onready var default_model_dir := DirAccess.open("models")


func _ready() -> void:
	policy_editor_screen.hide()
	x_input.text_changed.connect(_update_agent_count)
	y_input.text_changed.connect(_update_agent_count)
	
	start_training.pressed.connect(func():
		var training_grounds: TrainingGrounds = TRAINING_GROUNDS.instantiate()
		var field_size := _get_field_size()
		training_grounds.x = field_size.x
		training_grounds.y = field_size.y
		get_tree().change_scene_to_node(training_grounds)
		)
	
	policy_editor_button.pressed.connect(toggle_policy_editor_ui)
	close_button.pressed.connect(toggle_policy_editor_ui)
	
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


func toggle_policy_editor_ui() -> void:
	main_screen.visible =  policy_editor_screen.visible
	footer.visible = policy_editor_screen.visible
	policy_editor_screen.visible = not policy_editor_screen.visible
	
