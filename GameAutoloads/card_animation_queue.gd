extends Node2D



signal animationQueueEmpty

var animationQueue := []
var instantQueue := []

var currentAnimation:Dictionary = {}
var isAnimating := false

func _physics_process(delta: float) -> void:
	if not isAnimating:
		if not animationQueue.is_empty():
			animateNext()
			
	if not instantQueue.is_empty():
		handleInstants()
			
			

func queueAnimation(card:Card, animationFunction:Callable, waitingFunction:Callable=doNothing) -> void:
	
	print("AnimationQueue: Queue Animation for card: %s. Animation Function: %s " % [card.cardName, animationFunction])
			 
	animationQueue.append( 
		{"card":card, "animationFunction":animationFunction, "waitingFunction":waitingFunction} 
		)


func queueInstant(card:Card, animationFunction:Callable) -> void:
	instantQueue.append( {"card":card, "animationFunction":animationFunction} )


func queueWait(waitTime:float) -> void:
	print("AnimationQueue: Queue Wait")
	animationQueue.append({"waitTime": waitTime})



func animateNext() -> void:
	#### GET THE FIRST ITEM IN THE QUEUE
	var dict:Dictionary = animationQueue[0]
	currentAnimation = dict
	var tween:Tween = null
	
	#### WAIT ONLY: EMPTY DICT PROVIDED BY queueWait()
	if dict.has("waitTime"):
		print("AnimationQueue: AnimateNext: Just wait.")
		tween = create_tween()
		tween.tween_interval(dict.waitTime)		
		
		
	#### NORMAL ANIMATION
	elif MyTools.checkNodeValidity(dict.card):
		var card:Card = dict.card
		var f: Callable = dict.animationFunction
		
		print("AnimationQueue: Animate Next: Play animation for card: %s. Animation Function: %s " % [card.cardName, f])
		tween = f.call()
	
	
	#### SETUP THE QUEUE STUFF
	isAnimating = true	
	
	if tween:       ## WAIT FOR TWEEN ANIMATION
		await tween.finished
		onAnimationFinished()	
	else:           ## CONTINUE AT ONCE
		onAnimationFinished()
	
	
	
#### AN ANIMATION IS FINISHED, PLAY NEXT ANIMATION IN THE QUEUE
func onAnimationFinished() -> void:
	
	if currentAnimation.has("waitingFunction"):
		var waitingFunction: Callable = currentAnimation.waitingFunction
		if currentAnimation.card and waitingFunction:
			waitingFunction.call()
	
	#### REMOVE THE FIRST ITEM -> It's been processed now
	animationQueue.pop_front()	
	currentAnimation = {}
	isAnimating = false
	
	#### ANNOUNCE THAT THE QUEUE HAS BEEN EMPTIED FOR NOW
	if animationQueue.is_empty():
		animationQueueEmpty.emit()



#### ANIMATES AND REMOVES INSTANTS FROM THE QUEUE
#### INSTANT can only activate IF ITS CARD ISN'T BEING ANIMATED in main QUEUE
func handleInstants() -> void:
	var animatingCards: Array = getCurrentAndWaitingCards()
	var remainingInstants := []
	
	for anim:Dictionary in instantQueue:
		if anim.card in animatingCards:
			remainingInstants.append(anim)
		else:
			anim.animationFunction.call()
			
	instantQueue = remainingInstants
			


func getCurrentAndWaitingCards() -> Array:
	var animatingCards := []
	
	for anim:Dictionary in animationQueue:
		if anim.has("card"):
			animatingCards.append(anim.card)
	return animatingCards


func checkAndWaitQueueEmpty() -> bool:
	if not animationQueue.is_empty():
		await animationQueueEmpty
	return true


func doNothing() -> void:
	pass
