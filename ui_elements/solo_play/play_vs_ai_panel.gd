extends Control

const MODE: String = "SOLO"

@onready var play_vs_ai_button: Button = %PlayVsAiButton
@onready var configure_vs_ai_scenario: ConfigureScenarioButton = %ConfigureVsAiScenario
@onready var ai_selector: AiSelector = $AiSelector

func _ready() -> void:
	play_vs_ai_button.pressed.connect(start_vs_ai_play)


func start_vs_ai_play() -> void:
	var scenario := configure_scenario(configure_vs_ai_scenario.scenario)
	var sp := ScenarioPlayer.new(scenario, MODE, true)
	get_tree().change_scene_to_node(sp)

func configure_scenario(s: Scenario) -> Scenario:
	var copy: Scenario = s.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	assert(copy.ships.size() == 2, "to few ships!")
	var ai_ship := copy.ships[1]
	assert(ai_ship.mode is CM_Inference, "ai should run on inference")
	(ai_ship.mode as CM_Inference).model_path = ai_selector.selected
	
	return copy
