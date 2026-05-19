extends Control


const SPACE: PackedScene = preload("uid://cujdj2kfjxl54")
const TRAINING_GROUNDS: PackedScene = preload("uid://baw6jdbx8dn5d")
const SPACE_VS_AI = preload("uid://d0wbaw1yq1f4t")

@onready var play_solo_button: Button = %PlaySoloButton
@onready var play_vs_ai_button: Button = %PlayVsAiButton
@onready var start_training: Button = %StartTraining
@onready var x_input: LineEdit = %XInput
@onready var y_input: LineEdit = %YInput
@onready var number_of_agents: Label = %NumberOfAgents

func _ready() -> void:
	start_training.pressed.connect(func():
		var training_grounds: TrainingGrounds = TRAINING_GROUNDS.instantiate()
		var field_size := _get_field_size()
		training_grounds.x = field_size.x
		training_grounds.y = field_size.y
		get_tree().change_scene_to_node(training_grounds)
		)
	
	play_solo_button.pressed.connect(func(): get_tree().change_scene_to_packed(SPACE))
	
	play_vs_ai_button.pressed.connect(func():
		var space = SPACE_VS_AI.instantiate()
		get_tree().change_scene_to_node(space)
		)
	
	x_input.text_changed.connect(_update_agent_count)
	y_input.text_changed.connect(_update_agent_count)
	
func _get_field_size() -> Vector2i:
	return Vector2i(\
		int(x_input.text) if x_input.text else 0,\
		int(y_input.text) if y_input.text else 0,\
	)

func _update_agent_count(_input) -> void:
	var field_size := _get_field_size()
	number_of_agents.text = "=  %d Agents" % (field_size.x * field_size.y)
