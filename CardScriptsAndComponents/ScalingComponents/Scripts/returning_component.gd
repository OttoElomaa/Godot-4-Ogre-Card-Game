@icon("res://Art/icons/16x16/arrow_left.png")
@tool
extends Node
## Returns a Variant value to its parent, replacing its non-null values.
class_name ReturningComponent

##_args:
##'target': the frontmost card this skill targets.
##'targets': an Array of all cards this skill targets.
##'saved_targets': any targets saved within this CardAction's siblings by SaveTargets skill.
##'user': the user of this skill.
func get_return_value(_args:Dictionary) -> Variant:
	return null
