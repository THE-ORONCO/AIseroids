extends PanelContainer

const SPACE_MULTI = preload("uid://d07sfwm8fs1hr")

@export var scenario: Scenario

@onready var ai_demo_btn: Button = %AiDemoBtn
@onready var ai_1: AiSelector = %AI1
@onready var ai_2: AiSelector = %AI2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ai_demo_btn.pressed.connect(func(): 
		var space: SpaceMulti = SPACE_MULTI.instantiate()
		var sno := prepare_scenario(scenario)
		space.play_scenario(sno)
		get_tree().change_scene_to_node(space)
		)


func prepare_scenario(sno: Scenario) -> Scenario:
	var scenario_clone := sno.duplicate_deep()
	assert(scenario_clone.ships.size() >= 2, "no vs without multiple ships")
	for ship in scenario_clone.ships:
		assert(ship.mode is CM_Inference, "no battle without inference")
	
	(scenario_clone.ships[0].mode as CM_Inference).model_path = ai_1.selected
	(scenario_clone.ships[1].mode as CM_Inference).model_path = ai_2.selected
	
	return scenario_clone
