@tool
@icon('uid://dlh4p662b056r')
extends Node2D
class_name Scenario

enum ScenarioTypes {
	QUEST, ## A long, scenario with branching choices. Quests appear every 6 turns.
	ELITE_QUEST, ## An important quest which locks all other nodes from appearing until it is completed or failed. Elite quests appear every 15 turns.
	RANDOM_BATTLE, ## A short scenario with a battle and a reward. Random battles appear every 2-3 turns and last 3 turns.
	SHOP, ## A short scenario with a shop. Shops appear every 4 turns and last 1 turn.
	BONUS, ## A short scenario which offers a reward for free. Bonus appearance rate depends on what alliances the player has.
}

const Repeatable = [ScenarioTypes.RANDOM_BATTLE, ScenarioTypes.SHOP, ScenarioTypes.BONUS]

@export var zoneName := "The Lands"
@export var map_scene:PackedScene = null
@export var scenario_type = ScenarioTypes.QUEST

## Nodes within this scenario will be placed into a random location within the random_locations list. It it is empty, they can spawn anywhere. 
## Do note: this puts all nodes into the same random position. Use this for simple random events only.
@export var random_position = false:
	set(value):
		random_position = value
		notify_property_list_changed()

@export var random_locations: Array[Vector2] = []

## If anything is set, this scenario will only spawn on the map if you are allied with these groups.
@export var required_alliances: Array[Card.Group] = []

## If anything is set, this scenario will only spawn if these flags have been set in GameInfo.flags.
@export var required_flags: Array[String] = []

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

func _validate_property(property):
	if property.name == 'random_locations' and not random_position:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		
		
func get_all_nodes() -> Array:
	return %GameBoards.get_children()
