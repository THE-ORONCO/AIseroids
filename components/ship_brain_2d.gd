class_name ShipBrain2D
extends Node

@export var controller: AiController

@export_group("learning params")
enum ControlModes { INHERIT_FROM_SYNC, HUMAN, TRAINING, ONNX_INFERENCE, RECORD_EXPERT_DEMOS }
@export var control_mode: ControlModes = ControlModes.INHERIT_FROM_SYNC
@export var onnx_model_path := ""
@export var reset_after := 1000

@export_group("Record expert demos mode options")
## Path where the demos will be saved. The file can later be used for imitation learning.
@export var expert_demo_save_path: String
## The action that erases the last recorded episode from the currently recorded data.
@export var remove_last_episode_key: InputEvent
## Action will be repeated for n frames. Will introduce control lag if larger than 1.
## Can be used to ensure that action_repeat on inference and training matches
## the recorded demonstrations.
@export var action_repeat: int = 1

@export_group("Multi-policy mode options")
## Allows you to set certain agents to use different policies.
## Changing has no effect with default SB3 training. Works with Rllib example.
## Tutorial: https://github.com/edbeeching/godot_rl_agents/blob/main/docs/TRAINING_MULTIPLE_POLICIES.md
@export var policy_name: String = "shared_policy"

var onnx_model: ONNXModel

var heuristic := "human"
var done := false
var reward := 0.0
var n_steps := 0
var needs_reset := false

var _score_before := 0
var _health_before := 0
var _last_thrust_time := Time.get_ticks_msec()

func _init(c: ShipController) -> void:
	controller = c

func _ready():
	add_to_group("AGENT")
	_score_before = controller.score
	_health_before = controller.health


func get_obs() -> Dictionary:
	var ship_info := controller.get_ship_state()
	var sensor_info := controller.get_sensor_info()
	
	var obs := []
	obs.append_array(ship_info)
	#print(ship_info)
	obs.append_array(sensor_info)
	return {"obs": obs}


func get_reward() -> float:
	var r := 0.
	var score_delta := absi(_score_before - controller.score)
	var health_delta := absi(_health_before - controller.health)
	
	# remember health and score for the next iteration
	_score_before = controller.score
	_health_before = controller.health
	
	# small negative reward if the agent tried to shoot when no shots were available
	if controller.current_shots == 0 && controller.shoot:
		r -= 1
	
	# small negative reward if the ship had bullets left but took damage
	if controller.current_shots > 2 && health_delta >= 0:
		r -= .1
	
	# small bonus for keeping shots when not needed
	if controller.current_shots > 4:
		r += .05 * controller.current_shots
	
	# bonus reward if the thrust was not used and no damage was taken
	var now := Time.get_ticks_msec()
	if controller.thrust >= 0.001 || health_delta > 0:
		_last_thrust_time = now
	else:
		var thrust_pause := now - _last_thrust_time
		var no_thrust_reward := clampf(thrust_pause, 0., 1000.) / 1000. # up to 1 if no thrust for 1s
		r += no_thrust_reward
		
	# small negative reward if too close to other objects
	if controller.sensor is SensorSuite && (controller.sensor as SensorSuite).get_near_field_objects_count() > 0:
		r -= (controller.sensor as SensorSuite).get_near_field_objects_count() * .2
	
	return r + score_delta - health_delta


func get_action_space() -> Dictionary:
	return {
		"thrust": {
			"size": 1, 
			"action_type": "continuous",
			},
		"turn": {
			"size": 1,
			"action_type": "continuous",
			},
		"shoot": {
			"size": 1,
			"action_type": "discrete",
		}
	}


func set_action(action) -> void:
	controller.update_inputs(
		clampf(action["thrust"][0], 0, 1.0),
		clampf(action["turn"][0], -1.0, 1.0),
		action["shoot"] >= 0.5,
	)

#-----------------------------------------------------------------------------#


#-- Methods that sometimes need implementing using the "extend script" option in Godot --#
# Only needed if you are recording expert demos with this AIController
func get_action() -> Array:
	assert(false, "the get_action method is not implemented in extended AIController but demo_recorder is used")
	return []

# -----------------------------------------------------------------------------#

func _physics_process(_delta):
	n_steps += 1
	if n_steps > reset_after:
		needs_reset = true


func get_obs_space():
	# may need overriding if the obs space is complex
	var obs = get_obs()
	return {
		"obs": {"size": [len(obs["obs"])], "space": "box"},
	}


func reset():
	n_steps = 0
	needs_reset = false
	_score_before = controller.score
	_health_before = controller.health


func reset_if_done():
	if done:
		reset()


func set_heuristic(h):
	# sets the heuristic from "human" or "model" nothing to change here
	heuristic = h


func get_done():
	return done


func set_done_false():
	done = false


func zero_reward():
	reward = 0.0
