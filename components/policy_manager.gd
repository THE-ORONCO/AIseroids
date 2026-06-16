extends Node
## Autoloaded so enabled policies can be changd with UI.


const POLICIES_FOLDER_PATH: String = "res://components/policies/"
var policy_instances: Array[RewardPolicy] = []

func _ready() -> void:
	_discover_and_instantiate_policies()

func _discover_and_instantiate_policies() -> void:
	policy_instances.clear()
	var dir := DirAccess.open(POLICIES_FOLDER_PATH)
	if dir == null:
		push_error("Policy folder not found: %s" % POLICIES_FOLDER_PATH)
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".gd") and file_name != "reward_policy.gd":
			var script_path := POLICIES_FOLDER_PATH + file_name
			var script := load(script_path)
			if script:
				var instance = script.new()
				if instance is RewardPolicy:
					policy_instances.append(instance)
		file_name = dir.get_next()
	dir.list_dir_end()
	print(policy_instances)

## Should be called each episode start
func reset_all_policies() -> void:
	for p in policy_instances:
		if p: p.reset()
