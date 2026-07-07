class_name TrainingPanel
extends VBoxContainer


const TRAINING_GROUNDS: PackedScene = preload("uid://baw6jdbx8dn5d")

@onready var edit_solo_training_run_button: EditTrainingRunButton = %EditSoloTrainingRunButton
@onready var start_solo_training: Button = %StartSoloTraining
@onready var copy_solo_command: Button = %CopySoloCommand

@onready var edit_multi_training_run_button: EditTrainingRunButton = %EditMultiTrainingRunButton
@onready var start_multi_training: Button = %StartMultiTraining
@onready var copy_multi_command: Button = %CopyMultiCommand

@onready var continue_training: ContinueTrainingButton = %ContinueTraining

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	copy_solo_command.pressed.connect(func(): _command_to_clipboard(edit_solo_training_run_button.training_run))
	copy_multi_command.pressed.connect(func(): _command_to_clipboard(edit_multi_training_run_button.training_run))
	
	continue_training.continuation_selected.connect(func(run: TrainingRun):
		var previous_run := edit_solo_training_run_button.training_run
		var multiple_ships := previous_run.scenario.ships
		var new_run: TrainingRun = run.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
		new_run.scenario.ships = multiple_ships
		
		edit_solo_training_run_button.refresh(new_run)
		)
	continue_training.continuation_selected.connect(func(run: TrainingRun):
		var previous_run := edit_multi_training_run_button.training_run
		var multiple_ships := previous_run.scenario.ships
		var new_run: TrainingRun = run.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
		new_run.scenario.ships = multiple_ships
		edit_multi_training_run_button.refresh(new_run)
		)
	
	start_solo_training.pressed.connect(func():
		var run: TrainingRun = edit_solo_training_run_button.training_run.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
		_start_training(run)
		)
		
	start_multi_training.pressed.connect(func():
		var run: TrainingRun = edit_multi_training_run_button.training_run.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
		_start_training(run)
		)

func _command_to_clipboard(run: TrainingRun) -> void:
	var cmd := CmdUtils.create_command(run)
	DisplayServer.clipboard_set(cmd)

func _start_training(run: TrainingRun) -> void:
	var training_start_time := Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
	training_start_time = training_start_time.substr(0, training_start_time.length() - 3)
	var policy_log_save_path: String = PolicyManager.FOLDER_PATHS.logs + training_start_time + ".tres"
	PolicyManager.save_loaded_policy_collection(policy_log_save_path)
	
	run.policies = PolicyManager.loaded_policy_collection.policy_dict.values()
	
	var dir := FileUtils.next_training_run_dir(run)
	
	if !run.save_model_path:
		run.save_model_path = dir.path_join(run.experiment_name + ".zip")
	
	var training_grounds: TrainingGrounds = TRAINING_GROUNDS.instantiate()
	training_grounds.training_run = run
	#training_grounds.tree_exiting.connect(func(): _save_run(run, dir))
	ExitManager.exiting.connect(_save_run.bindv([run, dir]))
	get_tree().create_timer(10).timeout.connect(_save_run.bindv([run, dir]))
	
	get_tree().change_scene_to_node(training_grounds)
	
static func _save_run(run: TrainingRun, dir: String) -> void:
	if !DirAccess.dir_exists_absolute(dir):
		assert(false, "This directory should exist at the time of exiting")
	var save_path := dir.path_join(run.experiment_name + ".tres")
	var err := ResourceSaver.save(run, save_path)
	if err:	push_error("Error %d while saving %s" % [err, save_path])
	else: 	print("Created new training run %s in %s" % [run.experiment_name, dir])
