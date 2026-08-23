extends ZoneNode
class_name DialogueNode

@export var dialogue:DialogueResource

func _on_panel_container_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("LMB"):
			travel_screen.toggleUI(false)
			DialogueManager.show_dialogue_balloon(dialogue, "", [self])
			await DialogueManager.dialogue_ended
			resolve()
			print('Travel Screen: resolved ', name)
			travel_screen.toggleUI(true)
			travel_screen.updateZoneVisuals()
