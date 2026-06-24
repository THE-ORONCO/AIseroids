class_name PolicyEditorUI
extends ScrollContainer


const POLICY_EDIT = preload("uid://q57ustllbxm6")

@onready var v_box_container: VBoxContainer = $VBoxContainer


func _ready() -> void:
	update()


func update() -> void:
	assert(PolicyManager.loaded_policy_collection, "No policies where loaded")
	while v_box_container.get_child_count() > 0:
		var child = v_box_container.get_child(0)
		v_box_container.remove_child(child)
		child.queue_free()
	for key in PolicyManager.loaded_policy_collection.policy_dict:
		var policy = PolicyManager.loaded_policy_collection.policy_dict[key]
		var edit := POLICY_EDIT.instantiate() as PolicyEdit
		edit.target = policy
		v_box_container.add_child(edit)
