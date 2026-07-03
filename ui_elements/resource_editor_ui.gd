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
		var value: Variant = target.get(fp.prop_name)
		var setter := func(val): 
			target.set(fp.prop_name, val)
		var editor := _make_editor_for_type(value, setter, fp)
		if editor == null:
			continue
		editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		self.add_child(editor)

## the callable should just accept the new value and return nothing
static func _make_editor_for_type(v: Variant, setter: Callable, p: FieldProps) -> Control:

	if p.typ == TYPE_ARRAY:
		return _array_control(v, p)

	if p.typ == TYPE_OBJECT:
		return _object_control(v, p)


	return _basic_type_control(v, setter, p)

	# enums show up as TYPE_INT plus hint.
	# If you use @export_enum, you can use p["hint_string"] to map prop_names.
	# We'll treat it as int for now (good enough to start).
	#if p.typ == TYPE_INT:
		#return null

	#return null

static func _array_control(array: Array, p: FieldProps) -> Control:
	var fold := FoldableContainer.new()
	fold.title = p.prop_name
	fold.fold()
	
	var list := VBoxContainer.new()
	fold.add_child(list)

	var elem_type: int
	var elem_hint: int
	var elem_hint_string: String
	var array_nesting: int # TODO implement nested array stuff
	
	if p.hint == PROPERTY_HINT_TYPE_STRING:
		# see the docs why we do this weird string splitting
		var s := p.hint_string.split("/")
		match s.size():
			1: # no further type hints
				var structure := s[0].split(":")
				array_nesting = structure.size() - 1
				elem_type = int(structure[structure.size()-2])
			2: # type hints are present
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
			var control := _object_control(val, fp)
			list.add_child(control)
		# TODO do this for the rest of the types
		
		else:
			var line := _array_line(array)

			list.add_child(line)
			var fp = FieldProps.new({
				"name": str(i),
				"type": elem_type,
				"usage": p.usage,
				"hint": elem_hint,
				"hint_string": elem_hint_string
			})
			var control := _basic_type_control(val, func(new_val): array[i] = new_val, fp)
			line.add_child(control)
	
	var add_button := Button.new()
	add_button.text = "+"
	add_button.pressed.connect(func():
		
		# TODO maybe support objects here
		var default = default_for_variant_type(elem_type)
		array.resize(array.size() + 1)
		var last_index := array.size() - 1
		var fp = FieldProps.new({
				"name": str(last_index),
				"type": elem_type,
				"usage": p.usage,
				"hint": elem_hint,
				"hint_string": elem_hint_string
			})
		var control := _basic_type_control(default, func(new_val): array[last_index] = new_val, fp)
		
		var new_line := _array_line(array)
		new_line.add_child(control)
		
		var control_index := maxi(0,list.get_child_count() - 1)
		list.add_child(new_line)
		list.move_child(new_line, control_index)
		)
	list.add_child(add_button)
	
	
	return fold

static func _array_line(array: Array) -> Control:
	var delete_button := Button.new()
	delete_button.text = "🗑️"
	
	var line := HBoxContainer.new()
	line.add_child(delete_button)
	delete_button.pressed.connect(func():
		# This is kind of hacky and requires no other nodes to exist before the list of lines 
		var index := line.get_index() 
		line.queue_free()
		array.remove_at(index) 
		)
	return line

static func _object_control(v: Object, p: FieldProps) -> Control:
	var fold := FoldableContainer.new()
	fold.title = p.prop_name
	var recurse := ResourceUI.new()
	recurse.target = v
	fold.add_child(recurse)
	fold.fold()
	return fold

static func _basic_type_control(v: Variant, setter: Callable, p:FieldProps) -> Control:
	var row := HSplitContainer.new()
	row.split_offsets = [150]
	row.dragging_enabled = false
	row.dragger_visibility = SplitContainer.DRAGGER_HIDDEN
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var label := Label.new()
	label.text = p.prop_name
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	
	# bool		
	if p.typ == TYPE_BOOL:
		var cb := CheckBox.new()
		cb.button_pressed = bool(v)
		cb.toggled.connect(setter)
		row.add_child(cb)
		return row

	# int
	if p.typ == TYPE_INT:
		# TODO parse out min and max values
		var sb := SpinBox.new()
		sb.step = 1
		sb.min_value = -2147483648
		sb.max_value = 2147483647
		sb.value = int(v)
		sb.value_changed.connect(setter)
		row.add_child(sb)
		return row

	# float
	if p.typ == TYPE_FLOAT:
		# TODO parse out min and max values
		var sb := SpinBox.new()
		sb.step = 0.01
		sb.min_value = -1000000000.0
		sb.max_value = 1000000000.0
		sb.value = float(v)
		sb.value_changed.connect(setter)
		row.add_child(sb)
		return row

	# string
	if p.typ == TYPE_STRING:
		var le := LineEdit.new()
		le.text = str(v)
		le.text_submitted.connect(setter)
		le.text_changed.connect(setter)
		row.add_child(le)
		return row

	# Vector2
	if p.typ == TYPE_VECTOR2:
		var c := HBoxContainer.new()
		var x := SpinBox.new()
		var y := SpinBox.new()
		x.step = 0.01
		y.step = 0.01
		# TODO parse out min and max values
		x.prefix = "x "
		y.prefix = "y "
		x.value = v.x
		y.value = v.y
		x.value_changed.connect(func(val: float):
			setter.call(Vector2(val, y.value)))
		y.value_changed.connect(func(val: float):
			setter.call(Vector2(x.value, val)))
		c.add_child(x); c.add_child(y)
		row.add_child(c)
		return row

	# Color
	if p.typ == TYPE_COLOR:
		var cp := ColorPickerButton.new()
		cp.color = v
		cp.color_changed.connect(setter)
		row.add_child(cp)
		return row
		
	return null
	
static func default_for_variant_type(t: int):
	match t:
		TYPE_NIL: return null
		TYPE_BOOL: return false
		TYPE_INT: return 0
		TYPE_FLOAT: return 0.0
		TYPE_STRING: return ""
		TYPE_VECTOR2: return Vector2.ZERO
		TYPE_VECTOR2I: return Vector2i.ZERO
		TYPE_RECT2: return Rect2()
		TYPE_RECT2I: return Rect2i()
		TYPE_VECTOR3: return Vector3.ZERO
		TYPE_VECTOR3I: return Vector3i.ZERO
		TYPE_TRANSFORM2D: return Transform2D.IDENTITY
		TYPE_VECTOR4: return Vector4.ZERO
		TYPE_VECTOR4I: return Vector4i.ZERO
		TYPE_PLANE: return Plane()
		TYPE_QUATERNION: return Quaternion.IDENTITY
		TYPE_AABB: return AABB()
		TYPE_BASIS: return Basis()
		TYPE_TRANSFORM3D: return Transform3D.IDENTITY
		TYPE_COLOR: return Color(0, 0, 0, 1)
		TYPE_NODE_PATH: return NodePath()
		TYPE_RID: return RID()
		TYPE_OBJECT: return null
		TYPE_CALLABLE: return Callable()
		TYPE_SIGNAL: return Signal()
		TYPE_DICTIONARY: return {}
		TYPE_ARRAY: return []
		TYPE_PACKED_BYTE_ARRAY: return PackedByteArray()
		TYPE_PACKED_INT32_ARRAY: return PackedInt32Array()
		TYPE_PACKED_INT64_ARRAY: return PackedInt64Array()
		TYPE_PACKED_FLOAT32_ARRAY: return PackedFloat32Array()
		TYPE_PACKED_FLOAT64_ARRAY: return PackedFloat64Array()
		TYPE_PACKED_STRING_ARRAY: return PackedStringArray()
		TYPE_PACKED_VECTOR2_ARRAY: return PackedVector2Array()
		TYPE_PACKED_VECTOR3_ARRAY: return PackedVector3Array()
		TYPE_PACKED_COLOR_ARRAY: return PackedColorArray()
		_: return null
