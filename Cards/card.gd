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

@onready var castNode := $Effects/Cast
@onready var battleArtNode := $Effects/BattleArt
@onready var ritualNode := $Effects/Ritual
@onready var arrivalNode := $Effects/Arrival
@onready var onTurnNode := $Effects/OnTurn

@onready var specialTriggers := $Effects/SpecialCondition
@onready var payoffNode := $Effects/Payoff

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
var hasSunder: bool:
	get:
		return keywordHandler.hasSunder()
		
var hasDuelist: bool:
	get:
		return keywordHandler.hasDuelist()

var hasShadow: bool:
	get:
		return keywordHandler.hasShadow()


################################################## COUNTER NODE STUFF
var isPhased: bool:
	get:
		return countersNode.isPhased
	set(value):
		countersNode.togglePhased(value)


##########################################################


var cardsManager:Node = null

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
	
	if cardType == CardTypes.CREATURE:
		$Frontside/Background/Creature.show()
		$Frontside/Background/Spell.hide()
		$Frontside/StatsPanel/HBox/PowerLabel.text = "%d" % startingDamage
		$Frontside/StatsPanel/HBox/HealthLabel.text = "%d" % startingHealth
	else:
		$Frontside/Background/Creature.hide()
		$Frontside/Background/Spell.show()
		$Frontside/StatsPanel.hide()
		$Frontside/ActionState.hide()
	
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
	if hasSunder:
		effectTexts.append("Sunder") 
	if hasDuelist:
		effectTexts.append("Duelist") 
	if hasShadow:
		effectTexts.append("Shadow") 
	
	#### CHECK CAST, BATTLE ART, and RITUAL NODES
	
	#### IS IT RITUAL?
	if isRitual:
		var ritualText = ritualNode.createText()	
		effectTexts.append(ritualText) 
	
	#### IF NOT RITUAL, CREATE THE REST
	else:
		var arrivalText = arrivalNode.createText()	#### ARRIVAL
		effectTexts.append(arrivalText)
		
		var onTurnText = onTurnNode.createText()	#### ON TURN START
		effectTexts.append(onTurnText) 
		
			
		var castText = castNode.createText()  #### CAST	
		effectTexts.append(castText) 
		
		
		var battleArtText = battleArtNode.createText()	#### BATTLE ART (Card Combat)
		effectTexts.append(battleArtText) 
	
	var payoffText = payoffNode.createText()	#### BATTLE ART (Card Combat)
	effectTexts.append(payoffText) 
	
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
	
	#### SHARE INFO ON, IS CARD ENEMY
	for node in $Effects.get_children():
		node.setup(self)
	
	
			

func handleTurnStartReset():
	tempDamage = damage
	tempHealth = health
	

func handleTurnStartActions():
	#### TRIGGER ON TURN START EFFECTS
	if States.isStatePlay():
		onTurnNode.activate(null)



#### HANDLE CARD BEING PLAYED ON BOARD
func handleArrival():
	basicSetup()
	arrivalNode.activate(null)  #### TRIGGER ARRIVAL NODE
	if hasShadow:
		countersNode.togglePhased(true)
		statesPassive()
		
	updateCardVisuals()


func setInitialActionState():
	statesPassive()
	
	#### ENEMY CARDS ATTACK BY DEFAULT
	if isEnemyCard: 
		if not hasShadow:
			statesActive()


func updateCardVisuals():
	
	updateCardLabels()
	
	if actionState == CardActionStates.HAND:
		toggleManaCostIndicator(true)
		toggleActionStateIndicator(false)
	else:
		toggleManaCostIndicator(false)
		toggleActionStateIndicator(true)
	
	$Counters.updatePhasedVisuals()



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

#func rest():
	#resting = true
	#$BodyAnimations/RestTimer.start()

#### HANDLE REST
#### ANIMATE = ROTATE CARD IMMEDIATELY
#### DON'T ANIMATE = PLAY ANIMATION ON DELAY?? Why?
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
	stateHandler.get_node("PassiveIcon").hide()
	
	countersNode.togglePhased(false)
	
	
func statesPassive():
	actionState = CardActionStates.PASSIVE
	stateHandler.get_node("ActiveIcon").hide()
	stateHandler.get_node("PassiveIcon").show()


func statesInert():
	actionState = CardActionStates.INERT
	var s = $Frontside/ActionState
	s.get_node("ActiveIcon").hide()
	s.get_node("PassiveIcon").hide()
	

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
	
	#### FOR SUNDER DAMAGE GOING BELOW ZERO
	var isBrittle := false
	if tempHealth <= 0:
		isBrittle = true
	
	#### CHECK DESTROYED STATUS	
	var selfDestroyed := false
	if card.checkHasLethal(self):
		selfDestroyed = true
	
	#### HANDLE DAMAGE -> SUNDER Keyword
	if card.hasSunder:
		health -= card.tempDamage
		tempHealth -= card.tempDamage
	
	#### SUNDER CAN'T DESTROY CARD, UNLESS IT WAS ALREADY ZERO
	if tempHealth < 0:
		if isBrittle:
			selfDestroyed = true
		else:
			health = 0
	
	#### ANY CARD CAN DESTROY A CARD WITH 0 HEALTH
	if isBrittle:
		if card.tempDamage > 0:
			selfDestroyed = true
	
	#### UPDATE VISUALS AND RETURN DESTROYED STATUS
	updateCardLabels()
	return selfDestroyed


func checkHasLethal(otherCard:Card):
	var hasLethal := false
	if checkLethalTwo(otherCard):
		#### NO TRADE; ENEMY CARD DESTROYED
		if not otherCard.checkLethalTwo(self):
			hasLethal = true
		#### IF NO DUELIST, MUTUAL DESTRUCTION = TRADE
		elif not otherCard.hasDuelist:
			hasLethal = true
		elif tempDamage > 0 and otherCard.tempHealth <= 0:
			hasLethal = true
		
	return hasLethal

func checkLethalTwo(card:Card):
	var combatDamage:int = getCombatDamage()
	
	return combatDamage >= card.tempHealth


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



func turnOnBestiaryVisuals():
	toggleManaCostIndicator(true)
	toggleActionStateIndicator(false)
	toggleTraveling(false)
	
	$Frontside/CardNameBestiary.show()
	$Frontside/CardNameBestiary/Label.text = cardName
	
	updateCardLabels()


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

#######################################################################

func rotateRestingCard(willRest:bool):
	var degreesGoal = 0
	if willRest:
		degreesGoal = 25
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation_degrees", degreesGoal, 0.2)


func updateCardLabels():
	$Frontside/StatsPanel/HBox/HealthLabel.text = "%d" % tempHealth
	$Frontside/StatsPanel/HBox/PowerLabel.text = "%d" % tempDamage



func destroyAndAnimate(toAnimate:bool):
	if not isRitual:
		mySlot.isAvailable = true
		
	statesDestroy()
	if toAnimate:
		animateDestroyCard()


func animateDestroyCard():
	if actionState == CardActionStates.DESTROYED:
		$BodyAnimations.play("DestroyBoardCard")
	

func destroyCardTwo():
	cardsManager.moveToDiscard(self)



func toggleCardName(enable:bool):
	$Frontside/CardName.visible = enable
