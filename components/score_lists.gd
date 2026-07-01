class_name ScoreLists
extends Resource


const FILE_PATH: String = "user://highscore_lists.tres"

## {game_mode: String, list: {entry_name: String, score: int}}
@export var list_dict: Dictionary[String, Dictionary] = {}


static func load_or_create() -> ScoreLists:
	var res := ResourceLoader.load(FILE_PATH) as ScoreLists
	if res != null and res is ScoreLists:
		return res
	return ScoreLists.new()


func save_score(game_mode: String, entry_name: String, score: int) -> void:
	list_dict.game_mode.entry_name = score
	ResourceSaver.save(self, FILE_PATH)
