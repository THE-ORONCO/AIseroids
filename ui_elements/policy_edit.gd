class_name PolicyEdit
extends ResourceUI

@onready var policy_name: Button = $Header/PolicyName
@onready var check_box: CheckBox = $Header/CheckBox
@onready var parameter_container: VBoxContainer = $MarginContainer/ParameterContainer
@onready var margin_container: MarginContainer = $MarginContainer


func _ready() -> void:
	super._ready()
	margin_container.hide()
	policy_name.pressed.connect(_toggle_parameters)

func _build() -> void:
	for c in parameter_container.get_children():
		c.queue_free()

	var props := target.get_property_list()
	for p in props:
		# Only show real script properties (skip editor-only / internals)
		if not (p.has("name") && p.has("type") && p.has("usage") && p.has("hint") && p.has("hint_string")):
			continue

		var fp := FieldProps.new(p)
		
		if !(fp.usage & PropertyUsageFlags.PROPERTY_USAGE_SCRIPT_VARIABLE):
			continue
		
		if fp.prop_name.begins_with("_"):
			continue
		
		if fp.prop_name == "policy_name":
			policy_name.text = target.get(fp.prop_name).to_pascal_case()
			continue
		
		if fp.prop_name == "enabled":
			var policy_enabled = target.get(fp.prop_name)
			check_box.button_pressed = bool(policy_enabled)
			check_box.toggled.connect(func(val: bool): target.set(fp.prop_name, val))
			continue
		
		var parameter := _make_editor_for_type(target, fp)
		if parameter == null:
			continue
		parameter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		parameter_container.add_child(parameter)

func _toggle_parameters() -> void:
	margin_container.visible = not margin_container.visible
