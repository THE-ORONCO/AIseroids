class_name TrainingRunEdit
extends ConfirmationDialog

@export var training_run: TrainingRun
@onready var resource_ui: ResourceUI = %ResourceUI

func _ready() -> void:
	resource_ui.target = training_run
	resource_ui._build()

func refresh(new_run: TrainingRun) -> void:
	training_run = new_run
	resource_ui.rebuild(new_run)
