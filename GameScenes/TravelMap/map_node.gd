extends Node2D
class_name Map_Node

@export var index: String = 'Eastern Desert'
@export var connections: Array = ['Desert of the Gods', 'Salt Flats']
@export var node_type = 'basic'
@export var description = 'Eastern Desert'
@export var texture: CompressedTexture2D = preload("res://Art/ZoneComponents/Map_Node_Empty.png")
var difficulty = 0
@onready var Main_Node = get_parent().get_parent()

func _ready():
	$Sprite2D.texture = texture

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("LMB"):
		print('node_clicked')
		Main_Node.emit_signal("node_clicked", self)
