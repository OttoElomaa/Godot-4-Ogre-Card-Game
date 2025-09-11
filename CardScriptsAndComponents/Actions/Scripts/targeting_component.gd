extends Node2D

enum AutomaticTargetOptions {
	NONE, ALLIES, ENEMIES, ALL
	}
enum ManualTargetOptions {
	NONE, ALLY, ENEMY, ANY
	}

@export var automaticTargetGroup := AutomaticTargetOptions.NONE

@export var manualTargetGroup := ManualTargetOptions.NONE

@onready var castLine := $CastLine
var castLineShown := false
#enum DetailedTargetingOptions {NONE, STRONGEST, WEAKEST,}



var action:Node = null
var myCard:Card = null


func setup(action:Node, card:Card):
	self.action = action
	self.myCard = card
	endCastState()


func _physics_process(delta: float) -> void:
	
	if castLineShown:
		var mousePos := get_global_mouse_position()
		castLine.points[1] = mousePos - myCard.position



func _input(e: InputEvent) -> void:
	
	#### PROCESS CAST / ACTION-TARGETING STATE HERE	-> Not in BATTLESYSTEM Like ATTACK		
	if States.gameState == States.GameStates.CAST:
		
		if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
			if e.is_pressed():
				handleTargetingClicked()



func getTargets(isEnemy:bool) -> Array:
	var targets := []
	
	var aut := AutomaticTargetOptions
	var man := ManualTargetOptions
	
	
	match automaticTargetGroup:
		aut.ALLIES:
			return MyTools.getBoardCards(isEnemy)
		aut.ENEMIES:
			return MyTools.getBoardCards(!isEnemy)
		aut.ALL:
			var allCreatures:Array = MyTools.getBoardCards(isEnemy)
			allCreatures.append_array(MyTools.getBoardCards(!isEnemy))
			return allCreatures
			
	match manualTargetGroup:
		man.ALLY:
			return MyTools.getBoardCards(isEnemy)
		man.ENEMY:
			return MyTools.getBoardCards(!isEnemy)
		man.ANY:
			var allCreatures:Array = MyTools.getBoardCards(isEnemy)
			allCreatures.append_array(MyTools.getBoardCards(!isEnemy))
			return allCreatures
	
	return targets
	

#### MANUAL TARGETING STUFF
############################################################	

func beginManualTargeting():
	States.gameState = States.GameStates.CAST
	MyTools.toggleCardActionMenu(false, null)
	
	castLineShown = true
	$CastLine.show()
	castLine.points[0] = Vector2.ZERO



#### INPUT PROCESSING - TARGET CARD CLICK ATTEMPTED
func handleTargetingClicked():
	print("Click - Player trying to cast")
	
	#### GET CARDS AT MOUSE POSITION
	var results = MyTools.fetchMouseOverObjects(MyTools.COLLISION_MASK_CARD)
	prints("Cards found for casting: ", results.size())
	
	for r in results:
		var target:Card = MyTools.getCollidedObject(r)
		prints("Cast target card: ", target)
		
		var validTargets:Array = getTargets(action.isEnemy)
		if target in validTargets:
			action.activateSkillAfterTargeting([target])
		
	endCastState()
	return	
		


func checkIsManualTargeting():
	if manualTargetGroup != ManualTargetOptions.NONE:
		return true
	return false



func endCastState():
	castLineShown = false
	$CastLine.hide()
	
	if States.gameState == States.GameStates.CAST:
		States.gameState = States.GameStates.PLAY	
