extends MarginContainer


var zone:Node = null


@export_multiline var description := "This is what the button does."

var actionName:
	get:
		return $Panel/NameLabel.text



func setup(zone:Node):
	self.zone = zone



func buttonPressedActivate() -> void:
	pass # Replace with function body.


func _on_panel_mouse_entered() -> void:
	
	zone.updateActionDescription(actionName, description)
	


func buttonMouseEntered() -> void:
	zone.updateActionDescription(actionName, description)
