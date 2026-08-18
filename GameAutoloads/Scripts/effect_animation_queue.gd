extends Node2D

@onready var AnimatedPanel: PackedScene = preload("res://GameScenes/ParticlesAnimations/animated_panel.tscn")
@onready var GenericParticles: PackedScene = preload("res://GameScenes/ParticlesAnimations/generic_particles.tscn")


var animationQueue := []
var isAnimating := false

func _physics_process(delta: float) -> void:
	if not isAnimating:
		if not animationQueue.is_empty():
			animateNext()

func queueAnimation(card:Card, effect:CardAction, targetCards:Array, callable:Callable = animateGenericTrigger) -> void:
	animationQueue.append( {"card":card, "effect":effect, "targets":targetCards, "callable":callable} )

func animateNext():
	#### GET THE FIRST ITEM IN THE QUEUE
	var dict:Dictionary = animationQueue[0]
	
	#### NO VALID CARD OR EFFECT
	if (not MyTools.checkNodeValidity(dict.card) or not MyTools.checkNodeValidity(dict.effect)):
		animationQueue.pop_front()   ## REMOVE THE FIRST ITEM -> It's been processed now
		return
	isAnimating = true
	await dict["callable"].call(dict)

	animationQueue.pop_front()
	isAnimating = false

func animateGenericTrigger(dict):
	var card:Card = dict['card']
	var effect:CardAction = dict['effect']
	
	var animatedPanel:QueueAnimatedPanel = AnimatedPanel.instantiate() as QueueAnimatedPanel
	card.add_child(animatedPanel)
	animatedPanel.setupAndAnimate(card, effect)
	
	if effect.particleTexture:
		for target:Card in dict.targets:
			var particles:Node = GenericParticles.instantiate()
			target.add_child(particles)
	
	await animatedPanel.tree_exited
	
	
