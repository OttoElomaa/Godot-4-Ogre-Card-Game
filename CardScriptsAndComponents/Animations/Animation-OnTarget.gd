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

var awaiting = false
var active_coroutines = []

signal allCoroutinesFinished

func _process(delta):
	if awaiting:
		if active_coroutines.is_empty():
			allCoroutinesFinished.emit()

func _ready():
	$"SE Player".connect("finished", remove_completed.bind($"SE Player"))

func setup(action:CardAction, card:Card):
	myCard = card

func activate(dict:Dictionary):
	var targets = dict['targets']
	print('Animating on targets ', targets)
	for target in targets:
		for res:Resource in to_display:
			if res is PackedScene:
				var anim = instantiate_on_card(res, target) as Node
				active_coroutines.append(anim)
				anim.connect('tree_exited', remove_completed.bind(anim))
	for res:Resource in to_display:
		if res is AudioStream:
			$"SE Player".stream = res
			$"SE Player".play()
			active_coroutines.append($"SE Player")
	awaiting = true
	await allCoroutinesFinished
	awaiting = false

func remove_completed(obj:Variant):
	active_coroutines.erase(obj)

func instantiate_on_card(res:PackedScene, card:Card) -> Node:
	var new = res.instantiate()
	card.add_child(new)
	return new
