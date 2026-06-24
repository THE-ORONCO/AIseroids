class_name EditTrainingRunButton
extends Button

const TRAINING_RUN_EDIT:PackedScene = preload("uid://6eyrpuclq763")

signal finished_edit(tr: TrainingRun)

@export var training_run: TrainingRun = TrainingRun.new()
var _training_run_edit: TrainingRunEdit

func _ready() -> void:
	_training_run_edit = TRAINING_RUN_EDIT.instantiate()
	_training_run_edit.training_run = training_run
	self.add_child(_training_run_edit)
	
	_training_run_edit.confirmed.connect(func(): finished_edit.emit(training_run))
	self.pressed.connect(_show_editor)
	
func _show_editor() -> void:
	_training_run_edit.popup_centered_ratio(0.7)
	
