class_name TrainingPanel
extends VBoxContainer


signal training_started

const TRAINING_GROUNDS: PackedScene = preload("uid://baw6jdbx8dn5d")

@onready var edit_training_run_button: EditTrainingRunButton = %EditTrainingRunButton
@onready var start_training: Button = %StartTraining
@onready var copy_command: Button = %CopyCommand

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	copy_command.pressed.connect(_command_to_clipboard)
	
	start_training.pressed.connect(func():
		var training_start_time := Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
		training_start_time = training_start_time.substr(0, training_start_time.length() - 3)
		var policy_log_save_path: String = PolicyManager.FOLDER_PATHS.logs + training_start_time + ".tres"
		PolicyManager.save_loaded_policy_collection(policy_log_save_path)
		
		var training_grounds: TrainingGrounds = TRAINING_GROUNDS.instantiate()
		training_grounds.training_run = edit_training_run_button.training_run
		get_tree().change_scene_to_node(training_grounds)
		)

func _command_to_clipboard() -> void:
	var cmd := create_command(edit_training_run_button.training_run)
	DisplayServer.clipboard_set(cmd)

static func create_command(run: TrainingRun) -> String:
	var cmd := "python " + (".\\scripts\\" if OS.get_name() == "Windows" else "./scripts/") + "stable_baseline3_example.py"

	var args :PackedStringArray= []
	
	if run.experiment_name:		args.append_array(["--experiment_name", run.experiment_name])
	if run.experiment_dir:		args.append_array(["--experiemtn_dir", run.experiment_dir])
	if run.hyper_params:
		var hp := run.hyper_params
		if hp.start_seed: 		args.append_array(["--seed", hp.start_seed])
		if hp.net_arch:			args.append("--net_arch"); args.append_array(hp.net_arch)
	if run.resume_model_path:	args.append_array(["--resume_model_path", run.resume_model_path])
	if run.save_model_path:		args.append_array(["--save_model_path", run.save_model_path])
	if run.save_checkpoint_frequency: 
								args.append_array(["--save_checkpoint_frequency", run.save_checkpoint_frequency])
	if run.onnx_export_path:	args.append_array(["--onnx_export_path", run.onnx_export_path])
	if run.timesteps:			args.append_array(["--timesteps", run.timesteps])
	if run.linear_lr_schedule:	args.append("--linear_lr_schedule")
	if run.learning_rate:		args.append_array(["--learning_rate", run.learning_rate])
	if run.clip_range:			args.append_array(["--clip_range", run.clip_range])
	if run.n_steps:				args.append_array(["--n_steps", run.n_steps])
	
	for arg in args:
		cmd += " " + arg
		
	return cmd
