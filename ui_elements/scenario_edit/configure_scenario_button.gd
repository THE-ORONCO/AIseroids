class_name ConfigureScenarioButton
extends Button


const SCENARIO_EDIT: PackedScene = preload("uid://dowocsl0ivoiq")

signal finished_edit(sc: Scenario)

@export var scenario: Scenario

var _scenario_edit: ScenarioEdit

func _ready() -> void:
	_scenario_edit = SCENARIO_EDIT.instantiate()
	_scenario_edit.scenario = scenario
	self.add_child(_scenario_edit)
	
	_scenario_edit.confirmed.connect(func(): finished_edit.emit(scenario))
	self.pressed.connect(_show_editor)
	
func _show_editor() -> void:
	_scenario_edit.popup_centered_ratio(0.7)
