class_name ResourceUI
extends VBoxContainer

@export var target: Resource:
	set(val):
		target = val

class FieldProps:
	var prop_name: String
	var typ: int
	var usage:int
	var hint: int
	var hint_string: String
	
	func _init(p: Dictionary) -> void:
		prop_name = p.name
		typ = int(p.type) # Variant.Type enum as int
		usage = int(p.usage)
		hint = int(p.hint)
		hint_string = String(p.hint_string)

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

		var fp := FieldProps.new(p)
		
		if !(fp.usage & PropertyUsageFlags.PROPERTY_USAGE_SCRIPT_VARIABLE):
			continue
		
		if fp.prop_name.begins_with("_"):
			continue
		
		var editor := _make_editor_for_type(target, fp)
		if editor == null:
			continue
		editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		self.add_child(editor)


static func _make_editor_for_type(res: Resource, p: FieldProps) -> Control:
	var v = res.get(p.prop_name)

	if p.typ == TYPE_ARRAY:
		return _array_control(v, p)

	if p.typ == TYPE_OBJECT:
		return _object_control(v, p)


	var row := HSplitContainer.new()
	row.split_offsets = [150]
	row.dragging_enabled = false
	row.dragger_visibility = SplitContainer.DRAGGER_HIDDEN
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var label := Label.new()
	label.text = "- " + p.prop_name
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	
	# bool		
	if p.typ == TYPE_BOOL:
		var cb := CheckBox.new()
		cb.button_pressed = bool(v)
		cb.toggled.connect(func(val: bool): res.set(p.prop_name, val))
		row.add_child(cb)
		return row

	# int
	if p.typ == TYPE_INT:
		var sb := SpinBox.new()
		sb.step = 1
		sb.min_value = -2147483648
		sb.max_value = 2147483647
		sb.value = int(v)
		sb.value_changed.connect(func(val: float): res.set(p.prop_name, int(val)))
		row.add_child(sb)
		return row

	# float
	if p.typ == TYPE_FLOAT:
		var sb := SpinBox.new()
		sb.step = 0.01
		sb.min_value = -1000000000.0
		sb.max_value = 1000000000.0
		sb.value = float(v)
		sb.value_changed.connect(func(val: float): res.set(p.prop_name, val))
		row.add_child(sb)
		return row

	# string
	if p.typ == TYPE_STRING:
		var le := LineEdit.new()
		le.text = str(v)
		le.text_changed.connect(func(val: String): res.set(p.prop_name, val))
		row.add_child(le)
		return row

	# Vector2
	if p.typ == TYPE_VECTOR2:
		var c := HBoxContainer.new()
		var x := SpinBox.new()
		var y := SpinBox.new()
		x.step = 0.01
		y.step = 0.01
		x.value = v.x
		y.value = v.y
		x.value_changed.connect(func(val: float):
			res.set(p.prop_name, Vector2(val, y.value)))
		y.value_changed.connect(func(val: float):
			res.set(p.prop_name, Vector2(x.value, val)))
		c.add_child(x); c.add_child(y)
		row.add_child(c)
		return row

	# Color
	if p.typ == TYPE_COLOR:
		var cp := ColorPickerButton.new()
		cp.color = v
		cp.color_changed.connect(func(col: Color): res.set(p.prop_name, col))
		row.add_child(cp)
		return row

	# enums show up as TYPE_INT plus hint.
	# If you use @export_enum, you can use p["hint_string"] to map prop_names.
	# We'll treat it as int for now (good enough to start).
	if p.typ == TYPE_INT:
		return null
	

	return null

static func _array_control(array: Array, p: FieldProps) -> Control:
	var fold := FoldableContainer.new()
	fold.title = p.prop_name
	var vbox := VBoxContainer.new()
	fold.add_child(vbox)
	
	var elem_type: int
	var elem_hint: int
	var elem_hint_string: String
	var array_nesting: int # TODO implement nested array stuff
	
	if p.hint == PROPERTY_HINT_TYPE_STRING:
		var s := p.hint_string.split("/")
		match s.size():
			1: 
				var structure := s[0].split(":")
				array_nesting = structure.size() - 1
				elem_type = int(structure[structure.size()-1])
			2:
				var structure := s[0].split(":")
				array_nesting = structure.size() - 1
				elem_type = int(structure[structure.size()-1])
				var typing := s[1].split(":")
				elem_hint = int(typing[0])
				elem_hint_string = typing[1]
			_: push_error("unknown array structure")

	for i: int in range(array.size()):
		var val = array[i]
		if elem_hint == PROPERTY_HINT_RESOURCE_TYPE:
			var fp = FieldProps.new({
				"name": str(i),
				"type": elem_type,
				"usage": p.usage,
				"hint": elem_hint,
				"hint_string": elem_hint_string
			})
			#var recurse := ResourceUI.new()
			#recurse.target = val
			#vbox.add_child(recurse)
			return _object_control(val, fp)
	fold.fold()
	return fold

static func _object_control(v: Object, p: FieldProps) -> Control:
	var fold := FoldableContainer.new()
	fold.title = p.prop_name
	var recurse := ResourceUI.new()
	recurse.target = v
	fold.add_child(recurse)
	fold.fold()
	return fold
