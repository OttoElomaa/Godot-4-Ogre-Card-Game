extends ZoneNode
class_name DialogueNode

@export var dialogue:DialogueResource

func _on_area_2d_input_event(viewport, event:InputEvent, shape_idx):
	if event.is_action_pressed("LMB"):
		insta_resolve()
		zone.toggleUI()
		DialogueManager.show_dialogue_balloon(dialogue)
		await DialogueManager.dialogue_ended
		resolve()
		zone.toggleUI()
