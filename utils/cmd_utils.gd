class_name CmdUtils
extends Node

## generate a command line string to start the backend server given a training run 
static func create_command(run: TrainingRun) -> String:
	var cmd := "python " + (".\\scripts\\" if OS.get_name() == "Windows" else "./scripts/") + "stable_baselines3_example.py"

	var args :PackedStringArray= []
	
	if run.experiment_name:		args.append_array(["--experiment_name", run.experiment_name])
	if run.experiment_dir:		args.append_array(["--experiemtn_dir", run.experiment_dir])
	if run.hyper_params:
		var hp := run.hyper_params
		if hp.start_seed: 		args.append_array(["--seed", hp.start_seed])
		if hp.net_arch:			args.append("--net_arch"); args.append_array(hp.net_arch)
	if run.resume_model_path:	args.append_array(["--resume_model_path", run.resume_model_path])
	
	if run.save_model_path:		args.append_array(["--save_model_path", run.save_model_path])
	else:						args.append_array(["--save_model_path", FileUtils.next_training_run_dir(run).path_join(run.experiment_name + ".zip")])
	
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
