extends VBoxContainer

const SPACE_MULTI = preload("uid://d07sfwm8fs1hr")

@export var scenario: Scenario

@onready var ai_selector: AiSelector = %AiSelector
@onready var ai_demo_btn: Button = %AiDemoBtn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ai_demo_btn.pressed.connect(start_demo, PROPERTY_HINT_ONESHOT)


func prepare_scenario(sno: Scenario) -> Scenario:
	var scenario_clone := sno.duplicate_deep()
	assert(scenario_clone.ships.size() == 1, "only one ship allowed")
	assert(scenario_clone.ships[0].mode is CM_Inference, "no battle without inference")
	
	(scenario_clone.ships[0].mode as CM_Inference).model_path = ai_selector.selected
	
	return scenario_clone

func start_demo() -> void:
	var sno := prepare_scenario(scenario)
	var sp := ScenarioPlayer.new(sno)
	get_tree().change_scene_to_node(sp)
	
