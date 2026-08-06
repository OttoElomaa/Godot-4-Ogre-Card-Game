extends Skill

## Used as a basis for the new card. It is saved into SavedTargets; modify it as you will using Skills in a separate CardAction.
@export var template_card: PackedScene = null
var myAction:CardAction

func activate(targets:Array) -> bool:
	action.savedTargets.clear()
	action.savedTargets.append(template_card.instantiate())
	return true
