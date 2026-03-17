extends Node2D


var animationQueue := []
var currentAnimation:Dictionary = {}
var isAnimating := false

func _physics_process(delta: float) -> void:
	if not isAnimating:
		if not animationQueue.is_empty():
			animateNext()

func queueAnimation(card:Card, animationFunction:Callable, 
	animationLength:float, waitingFunction:Callable=doNothing) -> void:
		 
	animationQueue.append( 
		{"card":card, "animationFunction":animationFunction, "length":animationLength, "waitingFunction":waitingFunction} 
		)



func queueWait(waitTime:float):
	animationQueue.append({"waitTime": waitTime})



func animateNext():
	#### GET THE FIRST ITEM IN THE QUEUE
	var dict:Dictionary = animationQueue[0]
	currentAnimation = dict
	
	if dict.has("waitTime"):
		$AnimationTimer.wait_time = dict.waitTime
		$AnimationTimer.start()
		return
		
	
	var card:Card = dict.card
	var f:Callable = dict.animationFunction
	var animationLength:float = dict.length
	
	f.call()
	
	$AnimationTimer.wait_time = animationLength
	$AnimationTimer.start()


	#### SETUP THE QUEUE STUFF, REMOVE THE FIRST ITEM -> It's been processed now
	isAnimating = true
	animationQueue.pop_front()



#### AN ANIMATION IS FINISHED, PLAY NEXT ANIMATION IN THE QUEUE
func timeoutAnimationFinished() -> void:
	
	var waitingFunction: Callable = currentAnimation.waitingFunction
	waitingFunction.call()
	currentAnimation = {}
		
	isAnimating = false


func doNothing():
	pass
