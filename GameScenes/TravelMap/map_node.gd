@tool
extends Node2D
class_name Map_Node

@export var texture:Texture2D = preload("res://Art/CardArt/card-art-background-desert-mountain.png"):
	set(value):
		texture = value
		%TextureRect.texture = texture
var difficulty = 0
@export var node_name = '':
	set(value):
		node_name = value
		%NameLabel.text = node_name
var Main_Node = null

func setup(main:Node):
	Main_Node = main

func _ready():
	$PanelContainer/TextureRect.texture = texture

func _on_panel_container_gui_input(event):
	if event.is_action_pressed("LMB"):
		print('node_clicked')
		Main_Node.emit_signal("node_clicked", self)


func _on_panel_container_mouse_entered():
	%NodeName.show()
	
func _on_panel_container_mouse_exited():
	%NodeName.hide()
