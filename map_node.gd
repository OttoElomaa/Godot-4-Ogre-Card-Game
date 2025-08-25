extends Node2D
class_name Map_Node

@export var index = Vector2(0, 0)
@export var connections: Dictionary = {'up': Vector2(0, 1), 'down': Vector2(0,-1),
'left': Vector2(-1, 0), 'right': Vector2(1, 0)}
@export var node_type = 'captured'
@export var description = 'Captured!' + '\n' + 'You have taken over this node. Good job!'
@export var node_sprite = preload("res://Graphics/Map_Node_Empty.png")
var difficulty = 0
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
