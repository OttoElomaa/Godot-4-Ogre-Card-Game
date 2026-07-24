@icon('res://Art/icons/16x16/anim_frame.png')
extends Node2D
class_name AnimationActuator

var myCard:Card = null

enum actuator_types {ON_TARGET, ##The animation will be played once on each card the action targets.
ON_SCREEN ##The animation will be played once when the action succeeds.
}
##Choose the circumstances that the animation actuator activates.
@export var play_on: actuator_types
@export var to_display: Array[Resource] = []

func setup(action:CardAction, card:Card):
	myCard = card

func activate(target:Card):
	for res:Resource in to_display:
		if res is PackedScene:
			var anim = instantiate_on_card(res, target) as Node
#			await anim.tree_exited
		if res is AudioStream:
			$"SE Player".stream = res
			$"SE Player".play()
#			await $"SE Player".finished

func instantiate_on_card(res:PackedScene, card:Card) -> Node:
	var new = res.instantiate()
	card.add_child(new)
	return new
