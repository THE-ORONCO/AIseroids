class_name HighscoreBoard
extends PanelContainer

const SCORE_ENTRY = preload("uid://0ky1jyextjw7")

@onready var title: Label = %Title
@onready var scores_container: VBoxContainer = %ScoresContainer
@onready var close_button: Button = %CloseButton

func _ready() -> void:
	close_button.pressed.connect(hide)

func display_score_list(score_lists: ScoreLists, game_mode: String) -> void:
	assert(score_lists != null and game_mode != null and game_mode != "", "Invalid call! Insuficient arguments")
	clear()
	var score_list = score_lists.list_dict.game_mode
	for entry in score_list:
		var score_entry_instance := SCORE_ENTRY.instantiate() as ScoreEntry 
		scores_container.add_child(score_entry_instance)
		score_entry_instance.update(entry, score_list[entry])


func clear() -> void:
	while scores_container.get_child_count() > 0:
		var child = scores_container.get_child(0)
		scores_container.remove_child(child)
		child.queue_free()
