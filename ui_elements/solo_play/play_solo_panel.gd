extends VBoxContainer

const SPACE_MULTI: PackedScene = preload("uid://d07sfwm8fs1hr")

@onready var play_solo_button: Button = %PlaySoloButton
@onready var configure_scenario: ConfigureScenarioButton = %ConfigureScenario

func _ready() -> void:
	play_solo_button.pressed.connect(start_solo_play)


func start_solo_play() -> void:
	var space: SpaceMulti = SPACE_MULTI.instantiate()
	var sp := ScenarioPlayer.new(configure_scenario.scenario)
	get_tree().change_scene_to_node(sp)
