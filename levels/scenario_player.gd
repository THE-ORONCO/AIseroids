## Utility class to simply play one scenario for players and inference
class_name ScenarioPlayer
extends Node2D

const END_SCREEN: PackedScene = preload("uid://dlndycouolek5")
const SPACE_MULTI: PackedScene = preload("uid://d07sfwm8fs1hr")
const Sync: Script = preload("uid://cecwd02nv3ery")

var _end_after_round: bool = false 
var _game_mode: String
var _scenario: Scenario

func _init(scenario: Scenario, game_mode: String, end_after_round: bool = false) -> void:
	self._scenario = scenario
	self._game_mode = game_mode
	self._end_after_round = end_after_round
	
	
func _ready() -> void:
	var space: SpaceMulti = SPACE_MULTI.instantiate()
	assert(self.is_inside_tree(), "should be in tree")
	self.add_child(space)
	space.configure(_scenario)
	
	if space.ships_have_ai:
		var sync: Sync = Sync.new()
		sync.action_repeat = 1
		self.add_child(sync)
	
	if _end_after_round:
		space.round_finished.connect(_switch_to_results)
		

func _switch_to_results(scores: Dictionary[S_Team, int]) -> void:
	var end_screen: EndScreen = END_SCREEN.instantiate()
	end_screen.game_mode = _game_mode
	end_screen.scores = scores
	
	get_tree().change_scene_to_node.call_deferred(end_screen)
