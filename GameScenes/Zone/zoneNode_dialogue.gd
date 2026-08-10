extends ZoneNode
class_name DialogueNode

@export var dialogue:DialogueResource

func handleClick():
	travel_screen.toggleUI(false)
	DialogueManager.show_dialogue_balloon(dialogue)
	await DialogueManager.dialogue_ended
	resolve()
	print('Travel Screen: resolved ', name)
	travel_screen.toggleUI(true)
	travel_screen.updateZoneVisuals()
