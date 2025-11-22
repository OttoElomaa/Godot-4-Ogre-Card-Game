extends TargetingComponent
class_name ManualTargetingComponent

enum ManualTargetOptions {
	NONE, ALLIES, ENEMIES, ANY
}

@export var manualTargetGroup := ManualTargetOptions.NONE

var active = false
var target = null

signal target_acquired(target:Card)
signal aborted

func activate():
	active = true
	$CastingGraphic/GPUParticles2D.emitting = true

func deactivate():
	active = false
	$CastingGraphic/GPUParticles2D.emitting = false

func _physics_process(_delta):
	if active:
		$CastingGraphic.global_position = get_global_mouse_position()

func _input(event):
	if active:
		if event.is_action_pressed("LMB"):
			beginManualTargeting()
			handleTargetingClicked()
	#endCastState()
	#return	

func getTargets() -> Array:
	
	var conditions = []
	var success = true
	var man = ManualTargetOptions
	var eligible_targets = MyTools.getAllBoardCards()
	
	for child in get_children(true):
		if child is ConditionalComponent:
			conditions.append(child)
	print(name, 'has conditions ', conditions)
	
	for card:Card in MyTools.getAllBoardCards():
		match manualTargetGroup:
			man.ENEMIES:
				if myCard.isEnemyCard == card.isEnemyCard:
					eligible_targets.erase(card)
			man.ALLIES:
				if myCard.isEnemyCard != card.isEnemyCard:
					eligible_targets.erase(card)
			man.NONE:
				eligible_targets.erase(card)
		for cond in conditions:
			if cond is ConditionalComponent:
				if not cond.check(card, myCard):
					eligible_targets.erase(card)
		print(name, ' acquired targets ', eligible_targets)
	
	return eligible_targets


#### MANUAL TARGETING STUFF
############################################################	

func beginManualTargeting():
	MyTools.toggleCardActionMenu(false, null)
	States.gameState = States.GameStates.CAST
	#
	activate()

##### INPUT PROCESSING - TARGET CARD CLICK ATTEMPTED
func handleTargetingClicked():
	print("Click - Player trying to cast")
	##assert(1==2,"Is this working?")
	#
	##### GET CARDS AT MOUSE POSITION
	var results = MyTools.fetchMouseOverObjects(MyTools.COLLISION_MASK_CARD)
	prints("Cards found for casting: ", results.size())
	#
	for r in results:
		var tg:Card = MyTools.getCollidedObject(r)
		#
		#####
		if tg in getTargets():
			target = tg
	
	if target:
		prints("Cast target card: ", target)
		target_acquired.emit(target)
	else:
		aborted.emit()
		
	endCastState()
	return
	

func checkIsManualTargeting():
	if manualTargetGroup != ManualTargetOptions.NONE:
		return true
	return false



func endCastState():
	deactivate()
	
	#
	##### TEMPORARILY IGNORE MOUSE INPUT FROM OTHER NODES, LIKE CARD MANAGER
	States.toggleIgnoreMouseInput(true)
	
	if States.gameState == States.GameStates.CAST:
		States.gameState = States.GameStates.PLAY	
		##assert(1==2,"Is this working?")
