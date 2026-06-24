extends Node
## Autoloaded so policy settings can be changed with UI.


const FOLDER_PATHS: Dictionary = {
	"policy_scripts": "res://components/policies/",
	"logs": "res://logs/sb3/policy_collection_log/",
	"presets": "res://policy_collection_presets/",
}

var loaded_policy_collection: PolicyCollection:
	set(value):
		loaded_policy_collection = value
		_discover_and_instantiate_policies()
		reset_all_policies()


func _ready() -> void:
	loaded_policy_collection = _load_or_create()

## Adds all polices from the policy folder that are missing in the loaded collection.
func _discover_and_instantiate_policies() -> void:
	var dir := DirAccess.open(FOLDER_PATHS.policy_scripts)
	if dir == null:
		push_error("Policy folder not found: %s" % FOLDER_PATHS.policy_scripts)
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".gd") and file_name != "reward_policy.gd":
			var script_path := FOLDER_PATHS.policy_scripts + file_name
			var script := load(script_path)
			if script:
				var instance = script.new()
				if instance is RewardPolicy:
					if not loaded_policy_collection.policy_dict.has(instance.policy_name):
						instance.enabled = false
						loaded_policy_collection.policy_dict.set(instance.policy_name, instance)
		file_name = dir.get_next()
	dir.list_dir_end()


func _load_or_create() -> PolicyCollection:
	var res: PolicyCollection
	var last_used = _get_last_used_collection()
	if last_used is PolicyCollection:
		res = last_used
	else:
		res = PolicyCollection.new()
	return res


func _get_last_used_collection() -> Variant:
	var dir := DirAccess.open(FOLDER_PATHS.logs)
	if dir == null:
		push_error("folder not found: %s" % FOLDER_PATHS.logs)
		return null
	
	var files: Array[String] = []
	dir.list_dir_begin()
	var f := dir.get_next()
	while f != "":
		if !dir.current_is_dir() and (f.ends_with(".tres") or f.ends_with(".res")):
			files.append(f)
		f = dir.get_next()
	dir.list_dir_end()
	
	if files.is_empty():
		return null
	files.sort()
	var newest = files.back()
	var full_path := FOLDER_PATHS.logs.path_join(newest)
	return load(full_path)


func load_from_file(file_path: String) -> Error:
	var res := ResourceLoader.load(file_path, "PolicyCollection") as PolicyCollection
	if res is PolicyCollection:
		loaded_policy_collection = res
		return OK
	return FAILED


func save_loaded_policy_collection(save_path: String) -> Error:
	return ResourceSaver.save(loaded_policy_collection, save_path)

## Should be called each episode start
func reset_all_policies() -> void:
	for p: RewardPolicy in loaded_policy_collection.policy_dict.values():
		p.reset()
