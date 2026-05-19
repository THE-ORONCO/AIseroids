class_name TrainingGrounds
extends Node2D

const WRAP = preload("uid://dq5kaans1s87n")
const SHIP = preload("uid://cunuddi5si8ua")
const TRAINING_SPACE = preload("uid://6k24nqcbijxg")

@export_range(1, 16) var x: int = 4
@export_range(1, 9) var y: int = 3 
@export_range(1, 500) var padding: int = 500

@onready var camera: Camera2D = %Camera
@onready var agent_label: Label = %AgentLabel
@onready var end_ratios: Label = %EndRatios

var spaces: Array[Space] = []
var _camera_tween: Tweener = null
var _zoom_tween: Tweener = null
var _current_agent := 0

# TODO make dynamic with a dict of arbitrary end states
var _wins := 0.:
	set(val):
		_wins = val
		update_ratios()
var _timeouts := 0.:
	set(val):
		_timeouts = val
		update_ratios()
var _deaths := 0.:
	set(val):
		_deaths = val
		update_ratios()

func _ready() -> void:
	for dy: int in range(y):
		for dx: int in range(x):
			var space: Space = TRAINING_SPACE.instantiate()
			space.ai_mode = Space.AiMode.LEARNING
			self.add_child(space)
			
			# add metadata for clean logging
			space.set_meta("agent_no", dy * x + dx)
			for child in space.get_children():
				child.set_meta("agent_no", dy * x + dx)
			
			var playfield_width := space.wrap.extent.x
			var playfield_height := space.wrap.extent.y
			
			var xi := padding + (playfield_width + padding) * dx
			var yi := padding + (playfield_height + padding) * dy
			var pos: Vector2 = Vector2(xi,yi)
			
			space.global_position = pos
			
			space.score_keeper.best_changed.connect(func(_h): update_label())
			
			space.end_through_death.connect(func(): _deaths += 1.)
			space.end_through_timeout.connect(func(): _timeouts += 1.)
			space.end_through_win.connect(func(): _wins += 1.)
			
			spaces.append(space)

	place_camera.call_deferred(_current_agent)
	update_label.call_deferred()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_right"):
		_current_agent = ((_current_agent + 1) % spaces.size())
		update_label()
		place_camera(_current_agent)
	if Input.is_action_just_pressed("ui_left"):
		_current_agent = ((_current_agent - 1 + spaces.size()) % spaces.size())
		update_label()
		place_camera(_current_agent)
	if Input.is_action_just_pressed("ui_up"):
		zoom_camera(.2)
	if Input.is_action_just_pressed("ui_down"):
		zoom_camera(-.2)
		
	
func update_label() -> void:
	var best_score := 0
	var best_agent := 0
	for space_i in range(spaces.size()):
		var space := spaces[space_i]
		var best_in_space := space.score_keeper.best
		if best_in_space > best_score:
			best_score = space.score_keeper.best
			best_agent = space_i
		
	agent_label.text = "Agent %02d / %02d" % [_current_agent + 1, spaces.size()] \
					+  "\nBest: %05d  By: %02d" % [best_score, best_agent + 1]
					
func update_ratios() -> void:
	var sum := _wins + _deaths + _timeouts
	end_ratios.text= "✅ %5.1f%%\n❌ %5.1f%%\n⏱️ %5.1f%%" % [(_wins / sum) * 100., (_deaths / sum) * 100., (_timeouts / sum) * 100. ]

func place_camera(agent_no: int) -> void:
	var actual_agent_no := clampi(agent_no, 0, spaces.size() - 1)
	var space := spaces[actual_agent_no]
	var field_middle := space.global_position + space.wrap.extent / 2.
	
	if _camera_tween:
		_camera_tween.free()
	create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).tween_property(camera, "global_position", field_middle, .1)

func zoom_camera(amount: float) -> void:
	if camera.zoom.x + amount <= 0.01 || camera.zoom.x + amount > 10: return
	if _zoom_tween:
		_zoom_tween.free()
	create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).tween_property(camera, "zoom", camera.zoom + Vector2(amount, amount), .1)
	
