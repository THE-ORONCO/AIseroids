extends PanelContainer

const SPACE_MULTI = preload("uid://d07sfwm8fs1hr")

@onready var ai_demo_btn: Button = %AiDemoBtn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ai_demo_btn.pressed
	
