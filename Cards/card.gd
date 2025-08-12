extends Node2D
class_name Card


signal hoverOn
signal hoverOff

#### ACTIVE = Combatant, can be targeted, protects player from being targeted
#### PASSIVE = Can't be targeted, doesn't protect
#### ACTIVE / PASSIVE IS TRIGGERED in a right click menu on top of card
#### DESTROYED STATUS when the card is beaten in combat or otherwise destroyed
#### INERT REFERS to SPELLS and other cards that can't attack or cast
enum CardActionStates {
	ACTIVE, PASSIVE, DESTROYED, INERT, HAND
}
enum CardTypes {
	CREATURE, RITUAL,
}

var isRitual:
	get:
		return cardType == CardTypes.RITUAL

###### NODE REFERENCES
@onready var countersNode := $Counters
@onready var stateHandler := $Frontside/ActionState

@onready var actions := $Actions

@onready var keywordHandler := $KeywordHandler


####################################### EXPORT VARIABLES
@export var cardName := "Card Name"
@export var cardType := CardTypes.CREATURE
@export var subTypeStr := "Card Sub-Type"
var subTypes := []
var cardTypeStr := ""

@export_multiline var flavorText := ""

var cardArt:
	get:
		return $Frontside/Art.texture

@export var manaCost := 0
@export var startingDamage := 0
@export var startingHealth := 0

var damage := 0
var health := 0
var tempDamage := 0
var tempHealth := 0

var effectText := ""


######################################### CARD ACTION STATE
#### RESTING = Can't take card actions this turn, such as attack or cast.
#### RESTING IS TRIGGERED by attacking, or casting --> Unless "Haste/Vigilant" kind of effects
#### TRAVELING IS TRIGGERED by entering. It's summoning sickness
var actionState: CardActionStates = CardActionStates.ACTIVE
var isTraveling := false
var isResting := false
var allowInteract := true



####################################### KEYWORD HANDLER STUFF

		
var hasDuelist: bool:
	get:
		return keywordHandler.hasDuelist()




################################################## COUNTER NODE STUFF
var isPhased: bool:
	get:
		return countersNode.isPhased
	set(value):
		countersNode.togglePhased(value)


##########################################################


var cardsManager:CardsManager = null
var mainMenu: Node = null

var mySlot: CardSlot = null
var isEnemyCard := false
var myOffset := Vector2.ZERO




func _ready() -> void:
	cardsManager = get_tree().get_first_node_in_group("cardManager")
	cardsManager.connectCardSignal(self)
	
	subTypes = subTypeStr.split(" ")
	
	damage = startingDamage
	health = startingHealth
	
	handleTurnStartReset()
	
	var boardOrTempNode = get_parent()
	if boardOrTempNode is Node2D:
		myOffset = get_parent().position
	
	
	#$Frontside/Art.scale = Vector2(0.2, 0.2)
	
	if cardType == CardTypes.CREATURE:
		$Frontside/Background/Creature.show()
		$Frontside/Background/Spell.hide()
		$Frontside/Resources/Panel/HBox/PowerLabel.text = "%d" % startingDamage
		$Frontside/Resources/Panel/HBox/HealthLabel.text = "%d" % startingHealth
	else:
		$Frontside/Background/Creature.hide()
		$Frontside/Background/Spell.show()
		$Frontside/Resources.hide()
		$Frontside/ActionState.hide()
	
	#### SETUP FOR ALL ACTION SCRIPTS
	#### SHARE INFO ON, IS CARD ENEMY
	$Actions.setup(self)
	
	createEffectText()
	
	$Frontside/CardName/Label.text = cardName
	$Frontside/CardName.hide()
	
	
	
func createEffectText():
	
	
	match cardType:
		CardTypes.CREATURE:
			cardTypeStr = "Creature"
		CardTypes.RITUAL:
			cardTypeStr = "Ritual"
	
	
	subTypeStr = ""
	for type in subTypes:
		subTypeStr += type
		subTypeStr += " "
	subTypeStr = subTypeStr.rstrip(" ")
	
	#################################### EFFECT TEXT
	var l = $Frontside/EffectsLabel
	#var text = ""
	var effectTexts := []
	
	#### CHECK FROM KEYWORDS HANDLER
	if hasDuelist:
		effectTexts.append("Duelist") 
	
	
	#### CHECK CAST, BATTLE ART, and RITUAL NODES
	
	var actionHolderTexts := []
	actionHolderTexts = actions.createActionText()
	
	effectTexts.append_array(actionHolderTexts)
	
	effectText = ""
	for text in effectTexts:
		if text != "":
			effectText += text
			effectText += ". "
	
	effectText = effectText.rstrip(",. ")
	effectText = effectText.lstrip(",. ")
	#effectText = text
	l.text = effectText
	
	
########################################################		
func basicSetup():
	
	if isRitual:
		statesInert()
	
	#### SETUP FOR ALL ACTION SCRIPTS
	#### SHARE INFO ON, IS CARD ENEMY
	$Actions.setup(self)
	
	
	
	
			

func handleTurnStartReset():
	tempDamage = damage
	tempHealth = health
	

func handleTurnStartActions():
	#### TRIGGER ON TURN START EFFECTS
	if States.isStatePlay():
		actions.handleOnTurn(null) #### TRIGGER ON-TURN NODE



#### HANDLE CARD BEING PLAYED ON BOARD
func handleArrival():
	basicSetup()
	actions.handleArrival(null)  #### TRIGGER ARRIVAL NODE
	actions.handleOnTurn(null)   #### TRIGGER ON-TURN NODE
	
	#if hasShadow:
		#countersNode.togglePhased(true)
		#statesPassive()
		
	updateCardVisuals()


func setInitialActionState():
	statesPassive()
	
	#### ENEMY CARDS ATTACK BY DEFAULT
	if isEnemyCard: 
		#if not keywordHandler.hasShadow:
		statesActive()



#########################################################################
func _on_area_2d_mouse_entered() -> void:
	#emit_signal("hoverOn", self)
	MyTools.handleCardHover(true, self)


func _on_area_2d_mouse_exited() -> void:
	#emit_signal("hoverOff", self)
	MyTools.handleCardHover(false, self)



func removeMouseInteraction():
	#$Area2D.queue_free()
	allowInteract = false


func checkInteractAllowed() -> bool:
	return allowInteract


func toggleFrontSide(toShow:bool):
	if toShow:
		$Frontside.show()
	else:
		$Frontside.hide()


#############################################################

#### HANDLE REST
#### ANIMATE = ROTATE CARD IMMEDIATELY
#### DON'T ANIMATE = PLAY ANIMATION ON DELAY? ->TO PLAY ATTACK ANIMATION FIRST
func restAndAnimate(toAnimate:bool):
	isResting = true
	if toAnimate:
		rotateRestingCard(true)
	else:
		$BodyAnimations/RestTimer.start()


func wake():
	isResting = false
	rotateRestingCard(false)

########################################################


func switchStates():
	if actionState == CardActionStates.ACTIVE:
		statesPassive()
	elif actionState == CardActionStates.PASSIVE:
		statesActive()



func statesActive():
	actionState = CardActionStates.ACTIVE
	stateHandler.get_node("ActiveIcon").show()
	
	animateBlockingState(true)
	

func statesPassive():
	actionState = CardActionStates.PASSIVE
	stateHandler.get_node("ActiveIcon").hide()
	
	#### POSITION AS INDICATOR
	animateBlockingState(false)



func animateBlockingState(toBlock:bool):
	var newPos = mySlot.position
	
	#### POSITION AS INDICATOR
	if toBlock:
		var activeOffset := -50
		if isEnemyCard:
			activeOffset *= -1
		
		newPos.y += activeOffset
			
		#position.y = mySlot.position.y + activeOffset
		countersNode.togglePhased(false)
	#else:
		#position.y = mySlot.position.y
	
	MyTools.moveCardTweening(self, position, newPos)



func statesInert():
	actionState = CardActionStates.INERT
	var s = $Frontside/ActionState
	s.get_node("ActiveIcon").hide()
	
	

func statesDestroy():
	actionState = CardActionStates.DESTROYED	


func statesHand():
	actionState = CardActionStates.HAND


func toggleTraveling(enabled:bool):
	isTraveling = enabled
	if enabled:
		stateHandler.get_node("TravelingIcon").show()
	else:
		stateHandler.get_node("TravelingIcon").hide()


#func turnOffTravel() -> bool:
	#if isTraveling:
		#toggleTraveling(false)
		#return true
	#return false

##################################

func checkCanBlock() -> bool:
	#assert(1==2,"where is this called")
	if actionState == CardActionStates.ACTIVE:
		if not checkResting():
			return true
	return false


func checkCanAct() -> bool:
	if not checkInert():
		if checkAlive():
			if not checkResting():
				if not checkTraveling():
					return true
	return false



func checkInert() -> bool:
	if actionState == CardActionStates.INERT:
		return true
	return false

func checkResting() -> bool:
	return isResting

func checkTraveling() -> bool:
	return isTraveling


func checkAlive():
	return !(actionState == CardActionStates.DESTROYED)
		
########################################################



#### DEAL DAMAGE IF NECESSARY, AND RETURN ANSWER: DID THIS CARD DIE
func takeDamageAndCheckLethal(card:Card) -> bool:
	
	var selfCombatDamage:int = getCombatDamage()
	var enemyCombatDamage:int = card.getCombatDamage()
	
	#### CHECK DESTROYED STATUS 1: DUELIST
	var selfDestroyed := false
	if keywordHandler.hasDuelist():
		if selfCombatDamage >= card.tempHealth:
			return selfDestroyed
			
	
	#### DEAL DAMAGE
	var damageTaken = enemyCombatDamage
	
	if tempHealth < damageTaken:
		tempHealth = 0
	else:
		tempHealth -= damageTaken
	
	
	#### CHECK DESTROYED STATUS
	if tempHealth <= 0:
		selfDestroyed = true
	
	#### UPDATE VISUALS AND RETURN DESTROYED STATUS
	updateCardVisuals()
	return selfDestroyed



func getCombatDamage():
	var combatDamage = tempDamage
	
	if countersNode.isPhased:
		combatDamage += 1
		
	return combatDamage
	

###########################################################################
func toggleEnemyStatus(enabled:bool):
	isEnemyCard = enabled



func isOnSameSide(card:Card) -> bool:
	if isEnemyCard and card.isEnemyCard:
		return true
	if not isEnemyCard and not card.isEnemyCard:
		return true
	return false



func toggleManaCostIndicator(enable:bool):
	if enable:
		$Frontside/ManaCost.show()
		$Frontside/ManaCost/ManaCostLabel.text = "%d" % manaCost
	else:
		$Frontside/ManaCost.hide()


func toggleActionStateIndicator(enable:bool):
	if enable:
		$Frontside/ActionState.show()
		#$Frontside/ManaCost/ManaCostLabel.text = "%d" % manaCost
	else:
		$Frontside/ActionState.hide()



func turnOnBestiaryVisuals(mainMenu:Node):
	self.mainMenu = mainMenu
	
	toggleManaCostIndicator(true)
	toggleActionStateIndicator(false)
	toggleTraveling(false)
	
	$Frontside/CardNameBestiary.show()
	$Frontside/CardNameBestiary/Label.text = cardName
	
	updateCardLabels()



func handleEnterGraveyard():
	handleTurnStartReset()
	wake()
	
	toggleManaCostIndicator(true)
	toggleActionStateIndicator(false)
	toggleTraveling(false)
	
	updateCardLabels()



#### VISUALS - ANIMATIONS
#######################################################################################

func playAttackAnimation():
	if isEnemyCard:
		$BodyAnimations.play("EnemyAttack")
	else:
		$BodyAnimations.play("PlayerAttack")
	

#### FOR RESTING	
func timeoutRestAnimation() -> void:
	if checkResting():
		rotateRestingCard(true)



#### VISUALS
#######################################################################

func updateCardVisuals():
	
	updateCardLabels()
	
	if actionState == CardActionStates.HAND:
		toggleManaCostIndicator(true)
		toggleActionStateIndicator(false)
	else:
		toggleManaCostIndicator(false)
		toggleActionStateIndicator(true)
	
	$Counters.updatePhasedVisuals()



func updateCardLabels():
	
	#### LABELS
	$Frontside/Resources/Panel/HBox/HealthLabel.text = "%d" % tempHealth
	$Frontside/Resources/Panel/HBox/PowerLabel.text = "%d" % tempDamage
	
	#### GLOW
	var glow := $Frontside/Resources/Glow
	glow.get_node("PowerGlowUp").hide()
	glow.get_node("PowerGlowDown").hide()
	glow.get_node("HealthGlowUp").hide()
	glow.get_node("HealthGlowDown").hide()
	
	if tempDamage > startingDamage:
		glow.get_node("PowerGlowUp").show()
	elif tempDamage < startingDamage:
		glow.get_node("PowerGlowDown").show()
	
	if tempHealth > startingHealth:
		glow.get_node("HealthGlowUp").show()
	elif tempHealth < startingHealth:
		glow.get_node("HealthGlowDown").show()
		

###############################################################################
#### IF TOANIMATE == FALSE, THEN ANIMATION CALLED ELSEWHERE
#### IN ATTACK ANIMATION, TO BE SPECIFIC
func destroyAndAnimate(toAnimate:bool):
	if not isRitual:
		mySlot.isAvailable = true
		
	statesDestroy()
	if toAnimate:
		animateDestroyCard()



func animateDestroyCard():
	if actionState == CardActionStates.DESTROYED:
		$BodyAnimations.play("DestroyBoardCard")
	
	
#### CALLED IN ANIMATION "DestroyBoardCard"
func destroyCardTwo():
	cardsManager.moveToDiscard(self)

#################################################################################


func rotateRestingCard(willRest:bool):
	var degreesGoal = 0
	if willRest:
		degreesGoal = 25
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation_degrees", degreesGoal, 0.2)




func toggleCardName(enable:bool):
	$Frontside/CardName.visible = enable
