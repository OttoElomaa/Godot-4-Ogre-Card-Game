extends Node2D

@onready var AnimatedPanel: PackedScene = preload("res://GameScenes/ParticlesAnimations/animated_panel.tscn")
@onready var GenericParticles: PackedScene = preload("res://GameScenes/ParticlesAnimations/generic_particles.tscn")


var animationQueue := []
var isAnimating := false

func _physics_process(delta: float) -> void:
	if not isAnimating:
		if not animationQueue.is_empty():
			animateNext()

func queueAnimation(card:Card, effect:CardAction, targetCards:Array) -> void:
	animationQueue.append( {"card":card, "effect":effect, "targets":targetCards} )


func animateNext():
	#### GET THE FIRST ITEM IN THE QUEUE
	var dict = animationQueue[0]
	
	#### NO VALID CARD OR EFFECT
	if (not MyTools.checkNodeValidity(dict.card) or not MyTools.checkNodeValidity(dict.effect)):
		animationQueue.pop_front()   ## REMOVE THE FIRST ITEM -> It's been processed now
		return
	
	#### VALID CARD FOUND
	var card:Card = dict.card
	var effect:CardAction = dict.effect
	
	var animatedPanel:QueueAnimatedPanel = AnimatedPanel.instantiate() as QueueAnimatedPanel
	$Canvas.add_child(animatedPanel)
	animatedPanel.setupAndAnimate(card, effect)
	
	if effect.particleTexture:
		for target:Card in dict.targets:
			var particles:Node = GenericParticles.instantiate()
			target.add_child(particles)
	
	#### SETUP THE QUEUE STUFF, REMOVE THE FIRST ITEM -> It's been processed now
	animatedPanel.animationDone.connect(onAnimationFinished)
	isAnimating = true
	animationQueue.pop_front()
	
	
#### AN ANIMATION IS FINISHED, PLAY NEXT ANIMATION IN THE QUEUE
func onAnimationFinished():
	isAnimating = false
	
	
