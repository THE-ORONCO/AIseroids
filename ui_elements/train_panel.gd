class_name TrainingPanel
extends VBoxContainer

@onready var edit_training_run_button: EditTrainingRunButton = %EditTrainingRunButton

@onready var start_training: Button = %StartTraining

signal training_started

const TRAINING_GROUNDS: PackedScene = preload("uid://baw6jdbx8dn5d")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	start_training.pressed.connect(func():
		var training_grounds: TrainingGrounds = TRAINING_GROUNDS.instantiate()
		training_grounds.training_run = edit_training_run_button.training_run
		get_tree().change_scene_to_node(training_grounds)
		)
