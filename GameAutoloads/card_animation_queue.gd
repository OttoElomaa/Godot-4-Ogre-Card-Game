extends Node2D



signal animationQueueEmpty

var animationQueue := []

var responseQueue := []
var isAnimating := false

var responseAnimating := false
var isResponseBlocked := true


func _physics_process(delta: float) -> void:
	
	#### THE MAIN QUEUE ACTIVATES whenever there is ANIMATIONS IN THE QUEUE
	if not isAnimating:
		animateNext(animationQueue)
	
	#### THE RESPONSE QUEUE WAITS until ANIMATING=TRUE, SHUTS DOWN once it's emptied again
	if responseQueue.is_empty():
		responseAnimating = false
		if not isResponseBlocked:
			print("AnimationQueue: Pausing the response queue.")
			isResponseBlocked = true  #### CLOSE RESPONSE QUEUE FOR NOW, WHEN IT HAS EMPTIED
		
	if responseAnimating:
		pass
	elif isResponseBlocked:
		pass
	else:
		animateNext(responseQueue)
	
		
				


func startResponseQueue():
	if not isResponseBlocked:
		return
	if not responseQueue.is_empty():
		print("AnimationQueue: Starting the response queue!  Length: %d" % responseQueue.size())
		isResponseBlocked = false


##########################################
#### QUEUING PART
func queueAnimation(card:Card, animationFunction:Callable, waitingFunction:Callable=doNothing) -> void:
	print("AnimationQueue: Queue Animation for card: %s. Animation Function: %s " % [card.cardName, animationFunction])
	
	queueAnimationGeneric(card, animationQueue, animationFunction, waitingFunction)


func queueResponse(card:Card, animationFunction:Callable, waitingFunction:Callable=doNothing) -> void:
	print("AnimationQueue: Queue Response for card: %s. Animation Function: %s " % [card.cardName, animationFunction])
	
	queueAnimationGeneric(card, responseQueue, animationFunction, waitingFunction)


func queueAnimationGeneric(card:Card, queue:Array, animationFunction:Callable, waitingFunction:Callable=doNothing) -> void:		 
	queue.append( 
		{"card":card, "animationFunction":animationFunction, "waitingFunction":waitingFunction} 
		)

#### THIS QUEUE ITEM ONLY has a FUNCTION whose running TIME ISN'T RELEVANT to the queue
func queueFunction(function:Callable):
	print("AnimationQueue: Queue Function: %s" % function)
	animationQueue.append({"function": function})


func queueWait(waitTime:float) -> void:
	print("AnimationQueue: Queue Wait")
	animationQueue.append({"waitTime": waitTime})


###########################################
#### ANIMATING THINGS OFF THE QUEUE

func animateNext(queue:Array) -> void:
	if queue.is_empty():  #### EMPTY QUEUE, DO NOTHING
		return
	
	var queueText := "AnimationQueue: Animate Next."
	
	match queue:
		animationQueue:
			isAnimating = true	
		responseQueue:
			queueText = "AnimationQueue: Animate Next Response."
			responseAnimating = true
	
	#### GET THE FIRST ITEM IN THE QUEUE
	var dict:Dictionary = queue[0]
	var tween:Tween = null
	
	#### WAIT ONLY: EMPTY DICT PROVIDED BY queueWait()
	if dict.has("waitTime"):
		print("AnimationQueue: AnimateNext: Just wait.")
		tween = create_tween()
		tween.tween_interval(dict.waitTime)		
	
	#### THIS QUEUE ITEM ONLY has a FUNCTION whose running TIME ISN'T RELEVANT to the queue
	elif dict.has("function"):
		var f = dict.function
		if f is Callable:
			print("AnimationQueue: Animate Next: Call Function: %s" % f)
			f.call()
	
		
	#### NORMAL ANIMATION
	elif MyTools.checkNodeValidity(dict.card):
		var card:Card = dict.card
		var f: Callable = dict.animationFunction
		
		print("%s Play animation for card: %s. Animation Function: %s " % [queueText, card.cardName, f])
		tween = f.call()
	
	else:
		print("%s Animation failed due to invalid Card node." % queueText)
	
	
	if tween:       ## WAIT FOR TWEEN ANIMATION
		await tween.finished
		onAnimationFinished(queue)	
	else:           ## CONTINUE AT ONCE
		onAnimationFinished(queue)
	
	
	
#### AN ANIMATION IS FINISHED, PLAY NEXT ANIMATION IN THE QUEUE
func onAnimationFinished(queue:Array) -> void:
	var curr = queue.front()
	if curr is Dictionary and curr.has("waitingFunction"):
		
		#### PLAY THE ATTACHED FOLLOW-UP FUNCTION - Different from ANIMATENEXT
		var waitingFunction: Callable = curr.waitingFunction
		if curr.card and waitingFunction:
			if not waitingFunction == doNothing:
				print("AnimationQueue: Play Waiting Function for card: %s. Function: %s " % [curr.card.cardName, curr.waitingFunction])
				waitingFunction.call()
	
	#### REMOVE THE FIRST ITEM -> It's been processed now
	queue.pop_front()
	
	match queue:
		animationQueue:
			isAnimating = false
			if queue.is_empty():  #### ANNOUNCE IF THE PRIMARY QUEUE HAS BEEN EMPTIED FOR NOW
				animationQueueEmpty.emit()
				
		responseQueue:
			responseAnimating = false
			#if queue.is_empty():
				#print("AnimationQueue: Pausing the response queue.")
				#isResponseBlocked = true  #### CLOSE RESPONSE QUEUE FOR NOW, WHEN IT HAS EMPTIED



func checkAndWaitQueueEmpty() -> bool:
	if not animationQueue.is_empty():
		await animationQueueEmpty
	return true


func doNothing() -> void:
	pass
