class_name ResourceUI
extends VBoxContainer

@export var target: Resource


func _ready() -> void:
	if target == null:
		return
	_build()

func _build() -> void:
	# Clear
	for c in get_children():
		c.queue_free()

	var props := target.get_property_list()
	for p in props:
		# Only show real script properties (skip editor-only / internals)
		if not (p.has("name") && p.has("type") && p.has("usage") && p.has("hint") && p.has("hint_string")):
			continue

		var prop_name: String = p.name
		var typ := int(p.type) # Variant.Type enum as int
		var usage := int(p.usage)
		var hint := int(p.hint)
		var hint_string := String(p.hint_string)
		
		if !(usage & PropertyUsageFlags.PROPERTY_USAGE_SCRIPT_VARIABLE):
			continue		

		var editor := _make_editor_for_type(target, typ, prop_name, p)
		if editor == null:
			continue
		editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		self.add_child(editor)
		
		
		

static func _make_editor_for_type(res: Resource, typ: int, prop_name: String, p: Dictionary) -> Control:
	var v = res.get(prop_name)

	if typ == TYPE_OBJECT:
		var fold := FoldableContainer.new()
		fold.title = prop_name
		var recurse := ResourceUI.new()
		recurse.target = v
		fold.add_child(recurse)
		fold.fold()
		return fold


	var row := HSplitContainer.new()
	row.split_offsets = [150]
	row.dragging_enabled = false
	row.dragger_visibility = SplitContainer.DRAGGER_HIDDEN
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var label := Label.new()
	label.text = prop_name
	label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	row.add_child(label)
	
	# bool		
	if typ == TYPE_BOOL:
		var cb := CheckBox.new()
		cb.button_pressed = bool(v)
		cb.toggled.connect(func(val: bool): res.set(prop_name, val))
		row.add_child(cb)
		return row

	# int
	if typ == TYPE_INT:
		var sb := SpinBox.new()
		sb.step = 1
		sb.min_value = -2147483648
		sb.max_value = 2147483647
		sb.value = int(v)
		sb.value_changed.connect(func(val: float): res.set(prop_name, int(val)))
		row.add_child(sb)
		return row

	# float
	if typ == TYPE_FLOAT:
		var sb := SpinBox.new()
		sb.step = 0.01
		sb.min_value = -1000000000.0
		sb.max_value = 1000000000.0
		sb.value = float(v)
		sb.value_changed.connect(func(val: float): res.set(prop_name, val))
		row.add_child(sb)
		return row

	# string
	if typ == TYPE_STRING:
		var le := LineEdit.new()
		le.text = str(v)
		le.text_changed.connect(func(val: String): res.set(prop_name, val))
		row.add_child(le)
		return row

	# Vector2
	if typ == TYPE_VECTOR2:
		var c := HBoxContainer.new()
		var x := SpinBox.new()
		var y := SpinBox.new()
		x.step = 0.01
		y.step = 0.01
		x.value = v.x
		y.value = v.y
		x.value_changed.connect(func(val: float):
			res.set(prop_name, Vector2(val, y.value)))
		y.value_changed.connect(func(val: float):
			res.set(prop_name, Vector2(x.value, val)))
		c.add_child(x); c.add_child(y)
		row.add_child(c)
		return row

	# Color
	if typ == TYPE_COLOR:
		var cp := ColorPickerButton.new()
		cp.color = v
		cp.color_changed.connect(func(col: Color): res.set(prop_name, col))
		row.add_child(cp)
		return row

	# enums show up as TYPE_INT plus hint.
	# If you use @export_enum, you can use p["hint_string"] to map prop_names.
	# We'll treat it as int for now (good enough to start).
	if typ == TYPE_INT:
		return null
	

	return null
