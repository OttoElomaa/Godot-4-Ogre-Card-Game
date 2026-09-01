@icon("res://Art/icons/16x16/arrow_left.png")
extends Node
class_name ScalingComponent
## A scaling component returns an integer values and replaces all non-zero values of its Skill or Conditional parent's properties.

@export var multiplier:float = 1.0

##_args:
##'target': the frontmost card this skill targets.
##'targets': an Array of all cards this skill targets.
##'saved_targets': any targets saved within this CardAction's siblings by SaveTargets skill.
##'user': the user of this skill.
func get_scaling(_args: Dictionary) -> int:
	return 0
