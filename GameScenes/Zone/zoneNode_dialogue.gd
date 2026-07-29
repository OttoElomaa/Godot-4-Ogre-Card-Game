extends ZoneNode
class_name DialogueNode

@export var dialogue:DialogueResource

func handleClick():
	scenario.toggleUI()
	DialogueManager.show_dialogue_balloon(dialogue)
	await DialogueManager.dialogue_ended
	resolve()
	scenario.toggleUI()
