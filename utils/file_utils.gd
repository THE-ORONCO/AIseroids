class_name FileUtils
extends Node

static func flatten_directory(dir: DirAccess, filter: RegEx = null, recurse: bool = true) -> Array[String]:
	if !dir: 
		push_error(DirAccess.get_open_error())
		return []

	var files: Array[String] = []
	for file_name in dir.get_files():
		if !filter || !filter.search_all(file_name): continue
			
		var file_path := "%s/%s" % [dir.get_current_dir(), file_name]
		files.append(file_path)
		
	if recurse: 
		for sub_dir in dir.get_directories():
			var dir_path := "%s/%s" % [dir.get_current_dir(), sub_dir]
			files.append_array(flatten_directory(DirAccess.open(dir_path)))
	
	return files

static func next_training_run_dir(run: TrainingRun) -> String:
	var latest_exp_num := 0
	var latest_exp := ""
	var dir := DirAccess.open(run.experiment_dir)
	for file in dir.get_directories():
		if file.begins_with(run.experiment_name):
			var exp_num := int(file.replace(run.experiment_name, "").replace("_", ""))
			if exp_num > latest_exp_num:
				latest_exp_num = exp_num
				latest_exp = file
	
	if !latest_exp.is_empty():
		print("Found the experiment directory '%s' for the given run %s" % [latest_exp, run.experiment_name])
	
	var experiment_folder := run.experiment_name + "_" + str(latest_exp_num + 1)
	#var exp_dir := DirAccess.open(experiment_folder)
		
	return run.experiment_dir.path_join(experiment_folder)
