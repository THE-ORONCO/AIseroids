extends Control


const SPACE: PackedScene = preload("uid://cujdj2kfjxl54")
const TRAINING_GROUNDS: PackedScene = preload("uid://baw6jdbx8dn5d")
const AI_SHOWCASE: PackedScene = preload("uid://d0wbaw1yq1f4t")
const AI_DEMO_BUTTON = preload("uid://d0sqciovesnee")

@onready var play_solo_button: Button = %PlaySoloButton
@onready var start_training: Button = %StartTraining
@onready var x_input: LineEdit = %XInput
@onready var y_input: LineEdit = %YInput
@onready var number_of_agents: Label = %NumberOfAgents
@onready var ai_list: VBoxContainer = %AiList
@onready var file_dialogue_button: FileDialogueButton = %FileDialogueButton

@onready var onnx_regex := RegEx.create_from_string(".*\\.[oO][nN][nN][xX]$")
@onready var default_model_dir := DirAccess.open("models").get_current_dir()

func _ready() -> void:
	x_input.text_changed.connect(_update_agent_count)
	y_input.text_changed.connect(_update_agent_count)
	
	start_training.pressed.connect(func():
		var training_grounds: TrainingGrounds = TRAINING_GROUNDS.instantiate()
		var field_size := _get_field_size()
		training_grounds.x = field_size.x
		training_grounds.y = field_size.y
		get_tree().change_scene_to_node(training_grounds)
		)
	
	play_solo_button.pressed.connect(func(): get_tree().change_scene_to_packed(SPACE))
	
	
	var models_dir := DirAccess.open("models")
	
	var files := flatten_directory(models_dir)
	
	for file in files:
		var button := _create_button_for(file)
		ai_list.add_child(button)
	
	file_dialogue_button.file_selected.connect(func(file):
		var space = SPACE.instantiate()
		space.onnx_model_path = file
		get_tree().change_scene_to_node(space)
		)
	
	
func flatten_directory(dir: DirAccess) -> Array[String]:
	if !dir: 
		push_error(DirAccess.get_open_error())
		return []

	var files: Array[String] = []
	for file_name in dir.get_files():
		var result := onnx_regex.search_all(file_name)
		if !result: continue
			
		var file_path := "%s/%s" % [dir.get_current_dir(), file_name]
		files.append(file_path)
		
	for sub_dir in dir.get_directories():
		var dir_path := "%s/%s" % [dir.get_current_dir(), sub_dir]
		files.append_array(flatten_directory(DirAccess.open(dir_path)))
	
	return files
	
func _get_field_size() -> Vector2i:
	return Vector2i(\
		int(x_input.text) if x_input.text else 0,\
		int(y_input.text) if y_input.text else 0,\
	)

func _create_button_for(onnx_model_path: String) -> Button:
	var button_label := onnx_model_path.replace(default_model_dir + "/", "")
	var button: AiDemoButton = AI_DEMO_BUTTON.instantiate()
	button.text = button_label
	button.when_pressed_change_to(AI_SHOWCASE, onnx_model_path)
	return button

func _update_agent_count(_input) -> void:
	var field_size := _get_field_size()
	number_of_agents.text = "=  %d Agents" % (field_size.x * field_size.y)
