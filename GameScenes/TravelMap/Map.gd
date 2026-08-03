@tool
extends TextureRect
class_name Map

@export var map_name := ''

var markers:Array[Node]:
	get():
		return get_children()
