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
	
	print("AnimationQueue: Queued animation for card: " + card.cardName)	 
	animationQueue.append( 
		{"card":card, "animationFunction":animationFunction, "length":animationLength, "waitingFunction":waitingFunction} 
		)



func queueWait(waitTime:float):
	print("AnimationQueue: Queue Wait")
	animationQueue.append({"waitTime": waitTime})



func animateNext():
	#### GET THE FIRST ITEM IN THE QUEUE
	var dict:Dictionary = animationQueue[0]
	currentAnimation = dict
	var waitTime := 0.1
	
	#### WAIT ONLY: EMPTY DICT PROVIDED BY queueWait()
	if dict.has("waitTime"):
		print("AnimationQueue: AnimateNext: Just wait.")
		waitTime = dict.waitTime
	else:	
		#### NORMAL ANIMATION
		if MyTools.checkNodeValidity(dict.card):
			var card:Card = dict.card
			var f:Callable = dict.animationFunction
			var animationLength:float = dict.length
			
			print("AnimationQueue: Animate Next: Play animation for card: " + card.cardName)
			f.call()
			waitTime = animationLength
		
	$AnimationTimer.wait_time = waitTime
	$AnimationTimer.start()

	#### SETUP THE QUEUE STUFF, REMOVE THE FIRST ITEM -> It's been processed now
	isAnimating = true
	animationQueue.pop_front()



#### AN ANIMATION IS FINISHED, PLAY NEXT ANIMATION IN THE QUEUE
func timeoutAnimationFinished() -> void:
	
	if currentAnimation.has("waitingFunction"):
		var waitingFunction: Callable = currentAnimation.waitingFunction
		waitingFunction.call()
		
	currentAnimation = {}
	isAnimating = false



func doNothing():
	pass
