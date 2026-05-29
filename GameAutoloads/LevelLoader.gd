extends Node


signal before_level_change(from_id: StringName, to_id: StringName)
signal level_changed(id: StringName)

const LEVELS_DIR := "res://Resources/Scenarios/"

var _levels: Array[Dictionary] = []
var _current_id: StringName = &""


func _ready() -> void:
	_scanLevels()


func _scanLevels() -> void:
	#### CLEAR LEVELS, then SCAN THE MAIN LEVELS FOLDER
	_levels.clear()  
	_scan_dir(LEVELS_DIR, "")
	
	#### SORT BY FOLDER STRUCTURE AND ALPHABETICALLY
	_levels.sort_custom(func(a, b):
		if a.category != b.category:
			return a.category < b.category
		return a.id < b.id
	)

#### SCANS LEVEL FOLDER AND ITS SUB-FOLDERS
func _scan_dir(path: String, category: String) -> void:
	var dir := DirAccess.open(path)
	
	#### TOP DIR IS UNAVAILABLE
	if dir == null:
		push_warning("LevelCatalog: could not open " + path)
		return
	
	#### START READING FOLDER CONTENTS
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		var full_path := path + file_name
		
		#### SUB-FOLDER FOUND, OPEN IT
		if dir.current_is_dir():
			if not file_name.begins_with("."):   # skip . and ..
				var sub_category := category # Subfolder name becomes (or extends) the category
				if sub_category != "":
					sub_category += "/"
				sub_category += file_name
				_scan_dir(full_path + "/", sub_category)
		
		#### SCENE FILE FOUND, OPEN IT
		elif file_name.ends_with(".tscn"):
			var id := StringName(file_name.get_basename())
			_levels.append({
				"id": id,
				"path": full_path,
				"display_name": _prettify(file_name.get_basename()),
				"category": category,
			})
		file_name = dir.get_next()
	
	#### CLOSE THE STREAM WHEN DONE
	dir.list_dir_end()


#### FORMATTING - "forest_glade_01" → "Forest Glade 01"
func _prettify(raw: String) -> String:
	return raw.replace("_", " ").replace("-", " ").capitalize()



#######################################################
#### PUBLIC COMMANDS

func getAllLevels() -> Array[Dictionary]:
	return _levels


func getLevel(id: StringName) -> Dictionary:
	for level in _levels:
		if level.id == id:
			return level
	return {}


func hasLevel(id: StringName) -> bool:
	for level in _levels:
		if level.id == id:
			return true
	return false


func getCurrentLevelId() -> StringName:
	return _current_id



func changeTo(id: StringName) -> void:
	var level := getLevel(id)
	if level.is_empty():
		push_error("LevelCatalog: no level with id " + String(id))
		return

	before_level_change.emit(_current_id, id)
	_current_id = id
	await SceneSwitcher.switchToNewSceneFromFile(level.path)
	level_changed.emit(id)
	
	#if err != OK:
		#push_error("LevelCatalog: change_scene_to_file failed for " + level.path)
	
