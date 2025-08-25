extends NinePatchRect
class_name Tooltip

func _ready():
	Main.connect("object_mouseover", _on_object_mouseover)
	Main.connect('object_mouseout', _on_object_mouseout)
	visible = false

func _on_object_mouseover(obj:Object):
	visible = true
	$Desc.text = obj.description

func _process(delta):
	global_position = get_global_mouse_position()
	size = $Desc.size + $Desc.position + Vector2(0, 10)

func _on_object_mouseout():
	visible = false
