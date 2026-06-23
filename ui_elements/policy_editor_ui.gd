class_name PolicyEditorUI
extends ScrollContainer


const POLICY_EDIT = preload("uid://q57ustllbxm6")

@onready var v_box_container: VBoxContainer = $VBoxContainer


func _ready() -> void:
	for key in PolicyManager.policy_instances:
		var policy = PolicyManager.policy_instances[key]
		var edit := POLICY_EDIT.instantiate() as PolicyEdit
		edit.target = policy
		v_box_container.add_child(edit)
