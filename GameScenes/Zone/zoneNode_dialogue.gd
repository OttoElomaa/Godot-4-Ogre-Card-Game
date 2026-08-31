@icon('uid://b4o5ynx401rvf')

extends ZoneNode
class_name DialogueNode

@export var dialogue:DialogueResource

func handleClick():
	travel_screen.toggleUI(false)
	DialogueManager.show_dialogue_balloon(dialogue, "", [self])
	await DialogueManager.dialogue_ended
	travel_screen.toggleUI(true)
	resolve()
	print('Travel Screen: resolved ', name)
