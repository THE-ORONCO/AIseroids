class_name FileDialogueButton
extends Button

signal file_selected(path: String)

@onready var file_dialog: FileDialog = %FileDialog

func _ready() -> void:
	pressed.connect(file_dialog.popup)
	file_dialog.current_dir = "./models"
	file_dialog.file_selected.connect(file_selected.emit)
	
