class_name FileUtils
extends Node

static func flatten_directory(dir: DirAccess, filter: RegEx = null, recurse: bool = true) -> Array[String]:
	if !dir: 
		push_error(DirAccess.get_open_error())
		return []

	var files: Array[String] = []
	for file_name in dir.get_files():
		if !filter || !filter.search_all(file_name): continue
			
		var file_path := "%s/%s" % [dir.get_current_dir(), file_name]
		files.append(file_path)
		
	if recurse: 
		for sub_dir in dir.get_directories():
			var dir_path := "%s/%s" % [dir.get_current_dir(), sub_dir]
			files.append_array(flatten_directory(DirAccess.open(dir_path)))
	
	return files
