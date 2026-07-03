class_name ContinueTrainingButton
extends Button

signal continuation_selected(TrainingRun)

@onready var file_dialog: FileDialog = %FileDialog

func _ready() -> void:
	file_dialog.file_selected.connect(_handle_file_select)
	pressed.connect(open_file_dialogue)
	
func open_file_dialogue() -> void:
	file_dialog.popup_centered()

func _handle_file_select(path: String) -> void:
	var resource: Resource = ResourceLoader.load(path)
	if !resource is TrainingRun:
		push_error("Not a trainings run!")
		return

	var old_run: TrainingRun = resource
	var new_run: TrainingRun = old_run.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)

	# try to use the last state of the model
	if old_run.save_model_path && FileAccess.file_exists(old_run.save_model_path):
		new_run.resume_model_path = old_run.save_model_path

	else: # try to use the last checkpoint
		var checkpoint_path := old_run.checkpoint_path()
		
		var max_n_steps := -1
		var latest_log := ""
		for file in DirAccess.get_files_at(checkpoint_path):
			# something like: spaceshipV029_49995_steps.zip
			var name_parts := file.replace("_steps.zip", "").split("_")
			var n_steps := int(name_parts[name_parts.size() - 1])
			
			if n_steps > max_n_steps:
				max_n_steps = n_steps
				latest_log = file
		
		if max_n_steps < 0:
			push_error("Unable to locate logs to base the next run on in ", checkpoint_path)
			return
		
		new_run.resume_model_path = checkpoint_path.path_join(latest_log)

	# clear the save dir so that it will be regenerated
	new_run.save_model_path = ""
	
	continuation_selected.emit(new_run)
	
