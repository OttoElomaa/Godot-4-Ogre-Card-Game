extends Node2D

@onready var AnimatedPanel: PackedScene = preload("res://GameAutoloads/Components/animated_panel.tscn")
@onready var AnimatedParticlesScene: PackedScene = preload("res://GameAutoloads/Components/AnimatedParticles.tscn")


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
	var card:Card = dict.card
	var effect:CardAction = dict.effect
	
	var animatedPanel:QueueAnimatedPanel = AnimatedPanel.instantiate()
	$Canvas.add_child(animatedPanel)
	animatedPanel.setupAndAnimate(card, effect)
	
	if effect.particleTexture:
		for target:Card in dict.targets:
			var particles:AnimatedParticles = AnimatedParticlesScene.instantiate()
			$Sprites.add_child(particles)
			particles.setupAndAnimate(target.position, effect.particleTexture)
	
	#### SETUP THE QUEUE STUFF, REMOVE THE FIRST ITEM -> It's been processed now
	animatedPanel.animationDone.connect(onAnimationFinished)
	isAnimating = true
	animationQueue.pop_front()


#### AN ANIMATION IS FINISHED, PLAY NEXT ANIMATION IN THE QUEUE
func onAnimationFinished():
	isAnimating = false
	
