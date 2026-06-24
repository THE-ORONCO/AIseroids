class_name TrainingPannel
extends VBoxContainer

@export var trainging_run: TrainingRun

@onready var x_input: LineEdit = %XInput
@onready var y_input: LineEdit = %YInput
@onready var start_training: Button = %StartTraining
@onready var number_of_agents: Label = %NumberOfAgents

const TRAINING_GROUNDS: PackedScene = preload("uid://baw6jdbx8dn5d")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	x_input.text_changed.connect(_update_agent_count)
	y_input.text_changed.connect(_update_agent_count)
	
	start_training.pressed.connect(func():
		var training_grounds: TrainingGrounds = TRAINING_GROUNDS.instantiate()
		training_grounds.training_run = trainging_run
		get_tree().change_scene_to_node(training_grounds)
		)

func _get_field_size() -> Vector2i:
	return Vector2i(\
		int(x_input.text) if x_input.text else 0,\
		int(y_input.text) if y_input.text else 0,\
	)


func _update_agent_count(_input) -> void:
	var field_size := _get_field_size()
	number_of_agents.text = "=  %d Agents" % (field_size.x * field_size.y)
