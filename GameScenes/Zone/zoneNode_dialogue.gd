extends ZoneNode
class_name DialogueNode

@export var dialogue:DialogueResource

func handleClick():
	travel_screen.toggleUI()
	DialogueManager.show_dialogue_balloon(dialogue)
	await DialogueManager.dialogue_ended
	resolve()
	travel_screen.toggleUI()
	travel_screen.updateZoneVisuals()
