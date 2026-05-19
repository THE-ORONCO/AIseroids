extends Control


const SPACE: PackedScene = preload("uid://cujdj2kfjxl54")
const TRAINING_GROUNDS: PackedScene = preload("uid://baw6jdbx8dn5d")
const AI_SHOWCASE: PackedScene = preload("uid://d0wbaw1yq1f4t")

@onready var play_solo_button: Button = %PlaySoloButton
@onready var start_training: Button = %StartTraining
@onready var x_input: LineEdit = %XInput
@onready var y_input: LineEdit = %YInput
@onready var number_of_agents: Label = %NumberOfAgents

@onready var ai_v_1: Button = %"AI V1"
@onready var ai_v_2: Button = %"AI V2"
@onready var ai_v_3: Button = %"AI V3"
@onready var ai_v_4: Button = %"AI V4"
@onready var ai_v_5: Button = %"AI V5"


func _ready() -> void:
	x_input.text_changed.connect(_update_agent_count)
	y_input.text_changed.connect(_update_agent_count)
	
	start_training.pressed.connect(func():
		var training_grounds: TrainingGrounds = TRAINING_GROUNDS.instantiate()
		var field_size := _get_field_size()
		training_grounds.x = field_size.x
		training_grounds.y = field_size.y
		get_tree().change_scene_to_node(training_grounds)
		)
	
	play_solo_button.pressed.connect(func(): get_tree().change_scene_to_packed(SPACE))
	
	_set_up_button(ai_v_1, "models/V1.onnx")
	_set_up_button(ai_v_2, "models/V2.onnx")
	_set_up_button(ai_v_3, "models/V3.onnx")
	_set_up_button(ai_v_4, "models/V4.onnx")
	_set_up_button(ai_v_5, "models/V5.onnx")
	
	
	
func _get_field_size() -> Vector2i:
	return Vector2i(\
		int(x_input.text) if x_input.text else 0,\
		int(y_input.text) if y_input.text else 0,\
	)

func _set_up_button(button: Button, onnx_model_path: String) -> void:
	button.pressed.connect(func():
		var space: AiShowcase = AI_SHOWCASE.instantiate()
		space.onnx_model_path = onnx_model_path
		get_tree().change_scene_to_node(space)
		)

func _update_agent_count(_input) -> void:
	var field_size := _get_field_size()
	number_of_agents.text = "=  %d Agents" % (field_size.x * field_size.y)
