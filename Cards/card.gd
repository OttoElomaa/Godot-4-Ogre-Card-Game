@icon("res://Art/icons/16x16/character.png")
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
	ACTIVE, PASSIVE, DISCARD, INERT, HAND, DECK
}

enum CardStates {
	DECK, HAND, BOARD, GRAVEYARD
}

enum CardTypes {
	CREATURE, RITUAL,
}

var isRitual:
	get:
		return cardType == CardTypes.RITUAL

###### NODE REFERENCES

@onready var stateHandler := $Frontside/ActionState

@onready var actions := $Actions
@onready var effects := $Effects
@onready var keywordHandler := $KeywordHandler

@onready var effectTextLabel := $Frontside/EffectText

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

var keywords = []
var counters = []

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

func getKeywords():
	keywords = $KeywordHandler.collectKeywords()
	
	
func hasKeyword(keyword:String) -> bool:
	getKeywords()
	for i in keywords:
		if i.id == keyword:
			return true
	return false


func addKeyword(string:String):
	var keywordDirectory = 'res://CardScriptsAndComponents/Keywords/'
	var new_keyword: Keyword
	
	for i in DirAccess.get_files_at(keywordDirectory):
		print(i)
		if i.contains(string):
			print('Keyword Found')
			var loaded_keyword = load(keywordDirectory + i)
			new_keyword = loaded_keyword.instantiate()
			$KeywordHandler/MyKeywords.add_child(new_keyword)
			return
			
	new_keyword = Keyword.new()
	new_keyword.id = string
	$KeywordHandler/MyKeywords.add_child(new_keyword)




################################################## COUNTER NODE STUFF
var isPhased: bool:
	get:
		return effects.isPhased
	set(value):
		effects.togglePhased(value)


##########################################################
# EFFECT COUNTER STUFF

func getEffects():
	var counters = []
	for i in $Effects/Buff/Nodes.get_children():
		counters.append(i)
	for i in $Effects/Debuff/Nodes.get_children():
		counters.append(i)

func hasEffect(id:String):
	getEffects()
	for i in counters:
		if i.id == id:
			return true
	return false


##############################################################

var cardsManager:CardsManager = null
var mainMenu: Node = null

var mySlot: CardSlot = null
var isEnemyCard := false
var myOffset := Vector2.ZERO

var hurtColor:
	get:
		if isEnemyCard:
			return Color.GOLDENROD
		else:
			return Color.FIREBRICK

var healColor:
	get:
		if isEnemyCard:
			return Color.CADET_BLUE
		else:
			return Color.LIGHT_GREEN




func _ready() -> void:
	
	setup(null)
	
	
	#subTypes = subTypeStr.split(" ")
	#damage = startingDamage
	#health = startingHealth
	
	



func setup(gameBoard: GameBoard):
	
	if gameBoard:
		cardsManager = gameBoard.cardsManager
		cardsManager.connectCardSignal(self)
	
	SignalBus.connect("attacked", handleCombatActions)
	SignalBus.connect("defended", handleCombatActions)
	
	var boardOrTempNode = get_parent()
	if boardOrTempNode is Node2D:
		myOffset = get_parent().position
	
	
	#### SETUP FOR ALL ACTION SCRIPTS
	#### SHARE INFO ON, IS CARD ENEMY
	$Actions.setup(self)
	
	if cardType == CardTypes.CREATURE:
		updateCardNameAndBasicInfo(true)
		$Frontside/Background/Creature.show()
		$Frontside/Background/Spell.hide()
		
	else:
		updateCardNameAndBasicInfo(false)
		
		$Frontside/Background/Creature.hide()
		$Frontside/Background/Spell.show()
		$Frontside/Resources.hide()
		$Frontside/ActionState.hide()
	
	createEffectText()
	#$Frontside/CardName/Label.text = cardName
	
	$Frontside/CardName.hide()
	$Frontside/CardNameBestiary.hide()
	
	handleTurnStartReset()



func updateCardNameAndBasicInfo(isCreature:bool):
	subTypes = subTypeStr.split(" ")
	getKeywords()
	damage = startingDamage
	health = startingHealth
	
	createEffectText()
	
	$Frontside/CardName/Label.text = cardName
	
	if isCreature:
		$Frontside/Resources/Panel/HBox/PowerLabel.text = "%d" % startingDamage
		$Frontside/Resources/Panel/HBox/HealthLabel.text = "%d" % startingHealth

	
	
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
	var effectTexts := []
	
	#### CHECK FROM KEYWORDS HANDLER
	getKeywords()
	for keyword in keywords:
		effectTexts.append(keyword.id)
	
	
	#### CHECK ACTION NODES (CAST, BATTLE ART, and RITUAL NODES etc.)
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
	
	effectTextLabel.text = effectText
	return effectText
	
	
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
	

#func handleTurnStartActions():
#	#### TRIGGER ON TURN START EFFECTS
#	if States.isStatePlay():
#		actions.handleOnTurn() #### TRIGGER ON-TURN NODE



#### HANDLE CARD BEING PLAYED ON BOARD
func handleArrival():
	basicSetup()
	actions.awakenTriggers()#	actions.handleArrival()  #### TRIGGER ARRIVAL NODE
	SignalBus.arrival.emit([self])
#	actions.handleOnTurn()   #### TRIGGER ON-TURN NODE
	
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


func addEffect(appliedEffect: CardEffect):
	effects.addEffect(appliedEffect)


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
		effects.togglePhased(false)
	#else:
		#position.y = mySlot.position.y
	
	MyTools.moveCardTweening(self, position, newPos)



func statesInert():
	actionState = CardActionStates.INERT
	var s = $Frontside/ActionState
	s.get_node("ActiveIcon").hide()
	
	

func statesDestroy():
	actionState = CardActionStates.DISCARD	

func statesHand():
	actionState = CardActionStates.HAND

func statesDeck():
	actionState = CardActionStates.DECK



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
	return !(actionState == CardActionStates.DISCARD)

		
########################################################
####  COMBAT STUFF  #####################

#### DEAL DAMAGE IF NECESSARY, AND RETURN ANSWER: DID THIS CARD DIE
func takeCombatDamage(card:Card) -> int:
	
	var selfCombatDamage:int = getCombatDamageToTarget(card)
	var enemyCombatDamage:int = card.getCombatDamageToTarget(self)
	
	#### CHECK DESTROYED STATUS 1: DUELIST
	if hasKeyword('Duelist'):
		if selfCombatDamage >= card.tempHealth:
			return 0   #### DUELIST KILLS, SURVIVES -> FALSE
			
	
	#### DEAL DAMAGE
	var damageTaken = enemyCombatDamage
	if tempHealth < damageTaken:
		damageTaken = tempHealth

	tempHealth -= damageTaken
	updateCardVisuals()
	
	return damageTaken
	


func getCombatDamageToTarget(target:Card):
	#### BASELINE
	var combatDamage = tempDamage
	
	#### ATTACKER'S EFFECTS
	if effects.isPhased:
		combatDamage += 1
	
	#### END OF TARGETLESS DAMAGE CALCULATION
	if not target:
		return combatDamage
	
	#### TARGET'S EFFECTS
	if target.hasEffect('Doom'):
		combatDamage += 1
	
	return combatDamage



#### HANDLE CARD'S INTERNAL COMBAT STUFF (EXCEPT Damage Calculation)
func handleCombatActions(args: Array):
	var isAttacker = null
	var attacker = args[0]
	var defender = args[1]
	
	if attacker == self:
		isAttacker = true
		playAttackAnimation()
	elif defender == self:
		isAttacker = false



func checkAndHandleCombatDeath(isAttacker:bool) -> bool:
	if tempHealth <= 0:
		destroyAndAnimate(!isAttacker)
		return true
	
	#### SURVIVES, And IS ATTACKER	
	elif isAttacker:
		#### REST, OR TRAVEL If Vanguard
		if hasKeyword('Vanguard'):
			toggleTraveling(true)
		else:
			restAndAnimate(false)
			
			
	return false


######################################################################

func handleAttackingPortrait():
	playAttackAnimation()
	restAndAnimate(false)
	effects.togglePhased(false)
	

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
	
	updateCardVisuals()



func handleEnterGraveyard():
	handleTurnStartReset()
	actions.putTriggersToSleep()
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
	effects.updateEffectVisuals()
	
	if actionState == CardActionStates.HAND:
		toggleManaCostIndicator(true)
		toggleActionStateIndicator(false)
		
	elif States.gameState == States.GameStates.BESTIARY:
		toggleManaCostIndicator(true)
		
	else:
		toggleManaCostIndicator(false)
		toggleActionStateIndicator(true)
	
	


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
	statesDestroy()
	
	if mySlot:
		mySlot.isAvailable = true
		
	if toAnimate:
		playCardDestroyedAnimation()
	


func playCardDestroyedAnimation():
	if not checkAlive():
		$BodyAnimations.play("DestroyBoardCard")
	
	
#### CALLED IN ANIMATION "DestroyBoardCard"
func destroyCardTwo():
	cardsManager.moveToDiscard(self, isEnemyCard)

#################################################################################


func rotateRestingCard(willRest:bool):
	var degreesGoal = 0
	if willRest:
		degreesGoal = 25
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation_degrees", degreesGoal, 0.2)




func toggleCardName(enable:bool):
	$Frontside/CardName.visible = enable
