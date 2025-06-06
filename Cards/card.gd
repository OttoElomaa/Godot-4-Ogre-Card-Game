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
	ACTIVE, PASSIVE, DESTROYED, INERT
}

enum CardTypes {
	CREATURE, RITUAL,
}

var isSpell:
	get:
		return cardType == CardTypes.RITUAL



###########################################
@export var cardName := "Card Name"
@export var cardType := CardTypes.CREATURE

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




###############################################
#### RESTING = Can't take card actions this turn, such as attack or cast.
#### RESTING IS TRIGGERED by attacking, or casting --> Unless "Haste/Vigilant" kind of effects
#### TRAVELING IS TRIGGERED by entering. It's summoning sickness
var actionState: CardActionStates = CardActionStates.ACTIVE
var isTraveling := false
var resting := false
var allowInteract := true

var mySlot: CardSlot = null
var isEnemyCard := false
var myOffset := Vector2.ZERO

var cardsManager:Node = null

##########################################################
@onready var stateHandler := $Frontside/ActionState

@onready var castNode := $Effects/Cast
@onready var battleArtNode := $Effects/BattleArt
@onready var ritualNode := $Effects/Ritual

@onready var keywordHandler := $KeywordHandler

var hasSunder:
	get:
		return keywordHandler.hasSunder()
		
var hasDuelist:
	get:
		return keywordHandler.hasDuelist()







func _ready() -> void:
	var cardManager = get_parent().get_parent()
	cardManager.connectCardSignal(self)
	
	damage = startingDamage
	health = startingHealth
	
	turnStartReset()
	
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
	
	var l = $Frontside/EffectsLabel
	var text = ""
	
	#### CHECK FROM KEYWORDS HANDLER
	if hasSunder:
		text += "Sunder"
	if hasDuelist:
		text += "Duelist"
	
	#### CHECK CAST, BATTLE ART, and RITUAL NODES
	if isSpell:
		var ritualText = ritualNode.createText()	
		text += ritualText
	
	#### IF NOT RITUAL, CREATE THE REST
	else:
		var castText = castNode.createText()	
		text += castText
		
		if castText != "":
			text += "\n"
		
		var battleArtText = battleArtNode.createText()	
		text += battleArtText
	
	effectText = text
	l.text = effectText
	
	
	
	
func basicSetup():
	if isSpell:
		statesInert()
			

func turnStartReset():
	tempDamage = damage
	tempHealth = health
	
	updateCardLabels()




func _on_area_2d_mouse_entered() -> void:
	emit_signal("hoverOn", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hoverOff", self)



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

func rest():
	resting = true
	$BodyAnimations/RestTimer.start()

func restAndAnimate():
	resting = true
	rotateRestingCard(true)


func wake():
	resting = false
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
	return resting

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
	return tempDamage >= card.tempHealth


func toggleEnemyStatus(enabled:bool):
	isEnemyCard = enabled
	

###########################################################################

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


func playAttackAnimation():
	if isEnemyCard:
		$BodyAnimations.play("EnemyAttack")
	else:
		$BodyAnimations.play("PlayerAttack")
	


#### FOR RESTING	
func timeoutRestAnimation() -> void:
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



func destroyCardOne():
	if actionState == CardActionStates.DESTROYED:
		$BodyAnimations.play("DestroyBoardCard")
	

func destroyCardTwo():
	#self.queue_free()
	
	cardsManager.moveToDiscard(self)



func toggleCardName(enable:bool):
	$Frontside/CardName.visible = enable
