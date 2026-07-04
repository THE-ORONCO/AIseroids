class_name TrainingPanel
extends VBoxContainer


signal training_started

const TRAINING_GROUNDS: PackedScene = preload("uid://baw6jdbx8dn5d")

@onready var edit_training_run_button: EditTrainingRunButton = %EditTrainingRunButton
@onready var start_training: Button = %StartTraining
@onready var copy_command: Button = %CopyCommand
@onready var continue_training: ContinueTrainingButton = %ContinueTraining

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	copy_command.pressed.connect(_command_to_clipboard)
	
	
	continue_training.continuation_selected.connect(edit_training_run_button.refresh)
	
	start_training.pressed.connect(func():
		var training_start_time := Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
		training_start_time = training_start_time.substr(0, training_start_time.length() - 3)
		var policy_log_save_path: String = PolicyManager.FOLDER_PATHS.logs + training_start_time + ".tres"
		PolicyManager.save_loaded_policy_collection(policy_log_save_path)
		
		var run := edit_training_run_button.training_run.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
		run.policies = PolicyManager.loaded_policy_collection.policy_dict.values()
		
		var dir := FileUtils.next_training_run_dir(run)
		
		if !run.save_model_path:
			run.save_model_path = dir.path_join(run.experiment_name + ".zip")

		get_tree().root.tree_exiting.connect(func():
			if !DirAccess.dir_exists_absolute(dir):
				assert(false, "This directory should exist at the time of exiting")
			var save_path := dir.path_join(run.experiment_name + ".tres")
			var err := ResourceSaver.save(run, save_path)
			if err:	push_error("Error %d while saving %s" % [err, save_path])
			else: 	print("Created new training run %s in %s" % [run.experiment_name, dir])
		)
		
		var training_grounds: TrainingGrounds = TRAINING_GROUNDS.instantiate()
		training_grounds.training_run = run
		get_tree().change_scene_to_node(training_grounds)
		)

func _command_to_clipboard() -> void:
	var cmd := CmdUtils.create_command(edit_training_run_button.training_run)
	DisplayServer.clipboard_set(cmd)
