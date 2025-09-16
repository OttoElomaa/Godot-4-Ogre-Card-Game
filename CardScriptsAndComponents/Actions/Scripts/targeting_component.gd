extends Node2D

enum AutomaticTargetOptions {
	NONE, ALLIES, ENEMIES, ALL
	}
enum ManualTargetOptions {
	NONE, ALLY, ENEMY, ANY
	}

@export var automaticTargetGroup := AutomaticTargetOptions.NONE
@export var manualTargetGroup := ManualTargetOptions.NONE

@export var targetCardType := ""

##################################################

@onready var castLine := $CastLine
var isCasting := false
#enum DetailedTargetingOptions {NONE, STRONGEST, WEAKEST,}



var action:Node = null
var myCard:Card = null


func _ready() -> void:
	endCastState()


func setup(action:Node, card:Card):
	self.action = action
	self.myCard = card
	


func _physics_process(delta: float) -> void:
	
	if isCasting:
		if not castLine.visible:
			castLine.show()
		var mousePos := get_global_mouse_position()
		castLine.set_point_position(1, mousePos - myCard.position)
		#castLine.points[1] = () 
		#* MyTools.zoomVector.x



func _input(e: InputEvent) -> void:
	
	#### PROCESS CAST / ACTION-TARGETING STATE HERE	-> Not in BATTLESYSTEM Like ATTACK		
	if States.gameState == States.GameStates.CAST:
		if isCasting:
			#### PROCESS LEFT CLICK
			if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
				if e.is_pressed():
					handleTargetingClicked()



func getTargets(isEnemy:bool) -> Array:
	var targets := []
	
	var aut := AutomaticTargetOptions
	var man := ManualTargetOptions
	
	#### AUTOMATIC TARGETING
	match automaticTargetGroup:
		aut.ALLIES:
			targets = MyTools.getBoardCards(isEnemy)
		aut.ENEMIES:
			targets = MyTools.getBoardCards(!isEnemy)
		aut.ALL:
			var allCreatures:Array = MyTools.getBoardCards(isEnemy)
			allCreatures.append_array(MyTools.getBoardCards(!isEnemy))
			targets = allCreatures
	
	#### MANUAL TARGETING		
	match manualTargetGroup:
		man.ALLY:
			targets = MyTools.getBoardCards(isEnemy)
		man.ENEMY:
			targets = MyTools.getBoardCards(!isEnemy)
		man.ANY:
			var allCreatures:Array = MyTools.getBoardCards(isEnemy)
			allCreatures.append_array(MyTools.getBoardCards(!isEnemy))
			targets = allCreatures
	
	#### FILTERING OPTIONS AFTER TARGET GROUP SELECTION
	var filteredTargets = []
	if targetCardType == "": #### NO TYPE FILTER
		filteredTargets = targets
	#### FILTER TARGETS BY SUBTYPE -> For example only cards with BEAST subtype
	else:
		for card:Card in targets:
			if targetCardType in card.subTypes:
				filteredTargets.append(card)
	
	return filteredTargets
	

#### MANUAL TARGETING STUFF
############################################################	

func beginManualTargeting():
	#assert(1==2, "Is this working?")
	MyTools.toggleCardActionMenu(false, null)
	States.gameState = States.GameStates.CAST
	
	isCasting = true
	castLine.show()
	castLine.set_point_position(0, Vector2.ZERO)
	castLine.set_point_position(1, Vector2.ZERO)
	#castLine.points.append_array([Vector2.ZERO, Vector2.ZERO])



#### INPUT PROCESSING - TARGET CARD CLICK ATTEMPTED
func handleTargetingClicked():
	print("Click - Player trying to cast")
	#assert(1==2,"Is this working?")
	
	#### GET CARDS AT MOUSE POSITION
	var results = MyTools.fetchMouseOverObjects(MyTools.COLLISION_MASK_CARD)
	prints("Cards found for casting: ", results.size())
	
	for r in results:
		var target:Card = MyTools.getCollidedObject(r)
		prints("Cast target card: ", target)
		
		####
		var validTargets:Array = getTargets(action.isEnemy)
		if target in validTargets:
			if not target == myCard:
				action.activateSkillAfterTargeting([target])
				#assert(1==2,"Is this working?")
		
	endCastState()
	return	
		


func checkIsManualTargeting():
	if manualTargetGroup != ManualTargetOptions.NONE:
		return true
	return false



func endCastState():
	isCasting = false
	
	castLine.hide()
	castLine.set_point_position(0, Vector2.ZERO)
	castLine.set_point_position(1, Vector2.ZERO)
	
	#### TEMPORARILY IGNORE MOUSE INPUT FROM OTHER NODES, LIKE CARD MANAGER
	States.toggleIgnoreMouseInput(true)
	
	if States.gameState == States.GameStates.CAST:
		States.gameState = States.GameStates.PLAY	
		#assert(1==2,"Is this working?")
