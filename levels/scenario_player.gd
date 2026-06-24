## Utility class to simply play one scenario for players and inference
class_name ScenarioPlayer
extends Node2D

const SPACE_MULTI = preload("uid://d07sfwm8fs1hr")
const Sync: Script = preload("uid://cecwd02nv3ery")

var _scenario: Scenario
func _init(scenario: Scenario) -> void:
	self._scenario = scenario
	
func _ready() -> void:
	var space: SpaceMulti = SPACE_MULTI.instantiate()
	assert(self.is_inside_tree(), "should be in tree")
	self.add_child(space)
	space.configure(_scenario)
	
	if space.ships_have_ai:
		var sync: Sync = Sync.new()
		sync.action_repeat = 1
		self.add_child(sync)
