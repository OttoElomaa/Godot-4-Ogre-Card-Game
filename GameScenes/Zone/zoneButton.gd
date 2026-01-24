extends MarginContainer


var zone:Node = null


@export_multiline var description := "This is what the button does."

var actionName:
	get:
		return $Panel/NameLabel.text



func setup(zone:Node):
	self.zone = zone



func updateDescriptionPanel():
	zone.updateActionDescription(actionName, description)



func _on_panel_mouse_entered() -> void:
	updateDescriptionPanel()
	
	
func buttonMouseEntered() -> void:
	zone.updateActionDescription(actionName, description)
