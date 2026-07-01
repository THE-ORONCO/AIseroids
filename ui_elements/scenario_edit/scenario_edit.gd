class_name ScenarioEdit
extends ConfirmationDialog

@export var scenario: Scenario
@onready var resource_ui: ResourceUI = %ResourceUI

func _ready() -> void:
	resource_ui.target = scenario
	resource_ui._build()
