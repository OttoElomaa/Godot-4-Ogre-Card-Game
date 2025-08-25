extends Node2D
class_name Map_Node

@export var index = Vector2(0, 0)
#Contains every connection of the node. Each vector is ADDED to the node's own index
#to get the index of the connected node. If you're using arrow-key based movement, the
#keys with cardinal directions must be kept. Else, keys may be named anything.
@export var connections: Dictionary = {'up': Vector2(0, 1), 'down': Vector2(0,-1),
'left': Vector2(-1, 0), 'right': Vector2(1, 0)}
#Used to reference the type of the node within code, such as in the _node_entered function
#of level_select.
@export var node_type = 'base'
#Ingame flavor text. Used by the Tooltip scene.
@export var description = 'Captured!' + '\n' + 'You have taken over this node. Good job!'
@export var node_sprite = preload("res://Graphics/Map_Node_Empty.png")

@onready var Main_Node = get_parent().get_parent()

func _ready():
	$Sprite2D.texture = node_sprite

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("LMB"):
		Main_Node.emit_signal("node_clicked", self)

func _on_area_2d_mouse_entered():
	Main.emit_signal('object_mouseover', self)
	
func _on_area_2d_mouse_exited():
	Main.emit_signal('object_mouseout')

func change_into(target_scene:Map_Node):
	print('changing into', target_scene.node_type)
	node_type = target_scene.node_type
	description = target_scene.description
	node_sprite = target_scene.node_sprite
	$Sprite2D.texture = node_sprite
