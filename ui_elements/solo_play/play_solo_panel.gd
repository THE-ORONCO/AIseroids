extends Control

const MODE: String = "SOLO"
const SPACE_MULTI: PackedScene = preload("uid://d07sfwm8fs1hr")


@onready var play_solo_button: Button = %PlaySoloButton
@onready var configure_solo_scenario: ConfigureScenarioButton = %ConfigureSoloScenario

func _ready() -> void:
	play_solo_button.pressed.connect(start_solo_play)


func start_solo_play() -> void:
	var sp := ScenarioPlayer.new(configure_solo_scenario.scenario, MODE, true)
	get_tree().change_scene_to_node(sp)
