class_name HighscoreBoard
extends PanelContainer

const SCORE_ENTRY = preload("uid://0ky1jyextjw7")

## Only set to true when testing display of score list
@export var _test_mode: bool = false

@onready var title: Label = %Title
@onready var scores_container: VBoxContainer = %ScoresContainer
@onready var close_button: Button = %CloseButton


func _ready() -> void:
	close_button.pressed.connect(hide)
	if _test_mode:
		_test_display() 


func display_score_list(score_lists: ScoreLists, game_mode: String) -> void:
	assert(score_lists != null and game_mode != null and game_mode != "", "Invalid call! Insuficient arguments")
	assert(score_lists.list_dict.has(game_mode), "%s does not exist in the score lists dict." % game_mode)
	title.text =  game_mode + " Highscores"
	
	clear()
	var score_list: Dictionary = score_lists.list_dict[game_mode]
	var sorted_keys := score_list.keys()
	sorted_keys.sort_custom(func(a, b):
		return score_list[a] > score_list[b] # highest score first
	)
	for key in sorted_keys:
		var score_entry_instance := SCORE_ENTRY.instantiate() as ScoreEntry
		scores_container.add_child(score_entry_instance)
		score_entry_instance.update(key, score_list[key])


func clear() -> void:
	while scores_container.get_child_count() > 0:
		var child = scores_container.get_child(0)
		scores_container.remove_child(child)
		child.queue_free()


## Test function.
func _test_display() -> void:
	# Grundfälle
	var highscores := ScoreLists.load_or_create()
	highscores.save_score("Test", "A", 10)
	highscores.save_score("Test", "Bo", 9)
	highscores.save_score("Test", "Cris", 8)
	highscores.save_score("Test", "Daniel", 7)
	highscores.save_score("Test", "Elena", 6)
	highscores.save_score("Test", "F", 5)
	highscores.save_score("Test", "Gabi", 4)
	highscores.save_score("Test", "Hugo", 3)
	highscores.save_score("Test", "Ivana", 2)
	highscores.save_score("Test", "Julius", 1)

	highscores.save_score("Test", "Kira", 5)
	highscores.save_score("Test", "Leo", 5)
	highscores.save_score("Test", "Mara", 4)
	highscores.save_score("Test", "Nico", 4)
	highscores.save_score("Test", "Ona", 1)

	highscores.save_score("Test", "Pia", 0)
	highscores.save_score("Test", "Q", 0)

	highscores.save_score("Test", "Rex", 100)
	highscores.save_score("Test", "Sofia", 250)
	highscores.save_score("Test", "Tommaso", 1000)
	highscores.save_score("Test", "Ursula", 5000)
	highscores.save_score("Test", "ValentinaTheGreat", 100000)

	highscores.save_score("Test", "W", 1000)
	highscores.save_score("Test", "Xander", 5000)
	highscores.save_score("Test", "Y", 250)
	highscores.save_score("Test", "Zara", 100)
	highscores.save_score("Test", "Maximilian", 1)

	highscores.save_score("Test", "Noah", 2)
	highscores.save_score("Test", "Olivia", 7)
	highscores.save_score("Test", "Penelope", 6)

	display_score_list(highscores, "Test")
