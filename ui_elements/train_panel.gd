class_name TrainingPanel
extends VBoxContainer

@onready var edit_training_run_button: EditTrainingRunButton = %EditTrainingRunButton

@onready var start_training: Button = %StartTraining

signal training_started

const TRAINING_GROUNDS: PackedScene = preload("uid://baw6jdbx8dn5d")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	start_training.pressed.connect(func():
		var training_start_time := Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
		training_start_time = training_start_time.substr(0, training_start_time.length() - 3)
		var policy_log_save_path := PolicyManager.FOLDER_PATHS.logs + training_start_time + ".tres"
		PolicyManager.save_loaded_policy_collection(policy_log_save_path)
		var training_grounds: TrainingGrounds = TRAINING_GROUNDS.instantiate()
		training_grounds.training_run = edit_training_run_button.training_run
		get_tree().change_scene_to_node(training_grounds)
		)
