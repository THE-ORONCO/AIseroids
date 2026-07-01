class_name TextPromptWindow
extends Window


signal valid_text_submitted(text: String)

## Text displayed above the input field
@export var header_text: String
## Text diaplayed inside the input field as a palceholder 
@export var input_placeholder: String = "enter your text"

@onready var label: Label = %Label
@onready var line_edit: LineEdit = %LineEdit
@onready var confirm: Button = %Confirm
@onready var invalid_text_warning: AcceptDialog = %InvalidTextWarning

func _ready() -> void:
	label.text = header_text
	line_edit.placeholder_text = input_placeholder
	line_edit.text_submitted.connect(emit_valid_text)
	confirm.pressed.connect(func(): emit_valid_text.call(line_edit.text))

func emit_valid_text(input: String):
	print("input " + input)
	if input == null:
		line_edit.text = ""
		invalid_text_warning.show()
		return
	input.strip_edges()
	if input == "":
		line_edit.text = ""
		invalid_text_warning.show()
		return
	valid_text_submitted.emit(input)
	self.hide()
