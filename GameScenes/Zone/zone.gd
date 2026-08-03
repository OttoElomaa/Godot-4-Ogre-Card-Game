@tool
extends Node2D
class_name Scenario

@export var zoneName := "The Lands"
@export var map_scene:PackedScene = null

var editor_only_instance: Map:
	get():
		for child in get_children(true):
			if child is Map:
				return child
		return null
##################################

func _ready() -> void:
	if editor_only_instance:
		if not Engine.is_editor_hint():
			editor_only_instance.queue_free()
	else:
		if Engine.is_editor_hint():
			var instance = map_scene.instantiate() as Map
			add_child(instance)
			instance.owner = get_tree().edited_scene_root
			editor_only_instance = instance
			get_tree().edited_scene_root.set_editable_instance(instance, true)


func get_all_nodes() -> Array:
	return %GameBoards.get_children()
