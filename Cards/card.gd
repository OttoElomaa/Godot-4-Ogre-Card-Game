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
	ACTIVE, PASSIVE
}

#### LIMBO means the CARD IS BETWEEN STATES -> for example, NEITHER IN Board OR Graveyard
enum CardStates {
	DECK, HAND, BOARD, GRAVEYARD, LIMBO
}



enum CardTypes {
	CREATURE, ## HAS ATTACK AND HEALTH, CAN BE PUT INTO SLOTS AND CAN ACT IN BATTLE.
	RITUAL, ## CAN BE CAST FOR A ONE-TIME EFFECT.
	CHAMPION, ## HAS HEALTH BUT NOT ATTACK. CAN BE PLAYED OVER THE PLAYER PORTRAIT. BLOCKS DAMAGE
	## TAKEN BY THE PLAYER. ITS HEALTH CAN BE USED TO CAST ITS ABILITIES.
	STRUCTURE, ## IDENTICAL TO A CREATURE WITH APATHETIC KEYWORD. CANNOT MANUALLY ACT IN BATTLE.
	ITEM ## IDENTICAL TO A RITUAL WITH TRANSIENT KEYWORD. PURGED ON USE.
}

enum UpgradeStates {
	UNUPGRADED, PATH_1, PATH_2, PATH_3
}

enum Factions {
	GREEN_DEFIANCE, DESERT, CITY, OUTCAST
}

## Shows which loot table the card belongs to. Cards that cannot be gained from loot
## (like boss cards or summoned cards) should be set to NONE. Cards from the Generic
## pool can be recruited from anywhere. Cards from x_GENERIC pools can be always be recruited
## when in the given location, or always if they are from the player's faction.
enum Group {
	NONE, GENERIC, EQUIPMENT,
	## GREEN DEFIANCE
	GREEN_GENERIC, VINEMEN, WOODWOSES, SKULL_PRIESTS, GHARCH, GROVE_CLANS,
	## DESERT
	DESERT_GENERIC, SALKHI_HORDE, PYRECALLERS, HIGH_KINGDOM,
	## CITY
	CITY_GENERIC, THRONE, GUILDS, TEMPLES, ASTROMANCERS,
	## OUTCASTS
	OUTCAST_GENERIC, FREESLAYERS, UMUGITES, NECROMANCERS, MORLOCKS
}

var isRitual:
	get:
		return cardType == CardTypes.RITUAL

var isChampion:
	get:
		return cardType == CardTypes.CHAMPION

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

@export var group := Group.NONE

var gameBoard:GameBoard = null
var cardsManager:CardsManager = null
var battleSystem:BattleSystem = null
var mainMenu: Node = null

var mySlot: CardSlot = null
var isEnemyCard := false
var myOffset := Vector2.ZERO

var subTypes := []
var cardTypeStr := ""

@export_multiline var flavorText := ""

var cardArt:
	get:
		return $Frontside/Art.texture

@export var manaCost := 0
@export var startingDamage := 0
@export var startingHealth := 0
@export var upgraded := UpgradeStates.UNUPGRADED

var damage := 0
var health := 0
var tempDamage := 0
var tempHealth := 0

var keywords = []
#var counters = []

var effectText := ""

#region################################ AI VALUES

@export_subgroup('AI Behavior')
## This card becomes set as a blocker when summoned.
@export var block_on_arrival = true

enum actionMode {TANK, ## DOES NOT ACT ON ITS TURN, ONLY BLOCKS.
ATTACKER, ## IF THERE ARE BLOCKERS, ATTACKS THE ENEMY.
CASTER, ## IF THERE ARE BLOCKERS, USES ITS CAST ABILITY. 
}

## If the card acts during its turn, who it targets with manual casts.
@export var action_mode = actionMode.ATTACKER

## If the card acts during its turn, who it targets with manual tagets casts.
enum targetingMode {
WEAKEST,
STRONGEST
}

## If the card acts during its turn, who it targets with attacks/manual tagets casts.
@export var targeting_mode = targetingMode.WEAKEST

## Cards with the higher priority would be used sooner in their AI action step.
## Cards with equal priorities would act in an order based on their power, from
## strongest to weakest
@export var priority = 0

## Will never participate in a charge.
@export var will_not_charge = false

## Will attack even if it would be killed in the process.
@export var fearless = false
#endregion

#region################################# UPGRADE PATH 1

@export_subgroup('Upgrade Path #1')
@export var alt_card_name_1: String
@export var alt_actions_node_1: Node
@export var alt_keywords_1: PackedStringArray
@export var alt_art_1: Texture2D
@export var alt_damage_1: int
@export var alt_health_1: int
@export var alt_mana_cost_1: int
#endregion

#region################################# UPGRADE PATH 2

@export_subgroup('Upgrade Path #2')
@export var alt_card_name_2: String
@export var alt_actions_node_2: Node
@export var alt_keywords_2: PackedStringArray
@export var alt_art_2: Texture2D
@export var alt_damage_2: int
@export var alt_health_2: int
@export var alt_mana_cost_2: int
#endregion

#region################################# UPGRADE PATH 3

@export_subgroup('Upgrade Path #3')
@export var alt_card_name_3: String
@export var alt_actions_node_3: Node
@export var alt_keywords_3: PackedStringArray
@export var alt_art_3: Texture2D
@export var alt_damage_3: int
@export var alt_health_3: int
@export var alt_mana_cost_3: int
#endregion

######################################### CARD ACTION STATE
#### RESTING = Can't take card actions this turn, such as attack or cast.
#### RESTING IS TRIGGERED by attacking, or casting --> Unless "Haste/Vanguard" kind of effects
#### TRAVELING IS TRIGGERED by entering. It's summoning sickness
var actionState: CardActionStates = CardActionStates.ACTIVE
var cardState: CardStates = CardStates.DECK
var isTraveling := false
var isResting := false

var allowInteract := true
var allowEnemyUse := true




#region ######################################## STARTUP
func _ready() -> void:
	setup(null)
	
	
func setup_all_actions():
	$Actions.setup(self)
	$Actions.putTriggersToSleep()
	if alt_actions_node_1:
		alt_actions_node_1.setup(self)
		alt_actions_node_1.putTriggersToSleep()
	if alt_actions_node_2:
		alt_actions_node_2.setup(self)
		alt_actions_node_2.putTriggersToSleep()
	if alt_actions_node_3:
		alt_actions_node_3.setup(self)
		alt_actions_node_3.putTriggersToSleep()


func setup(gameBoard: GameBoard):
	print(cardName, ' sets up.')
	if gameBoard:
		self.gameBoard = gameBoard
		print(cardName, ' has gameboard')
		cardsManager = gameBoard.cardsManager
		battleSystem = gameBoard.battleSystem
		cardsManager.connectCardSignal(self)

	
	var boardOrTempNode = get_parent()
	if boardOrTempNode is Node2D:
		myOffset = get_parent().position
	
	change_upgrade_state(upgraded)
	
	#### SETUP FOR ALL ACTION SCRIPTS
	#### SHARE INFO ON, IS CARD ENEMY
#	actions.setup(self)
	reset_shaders()
	
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
	updateCardVisuals()
	$Effects.updateEffectVisuals()
	#$Frontside/CardName/Label.text = cardName
	
	$Frontside/CardName.hide()
	$Frontside/CardNameBestiary.hide()
	
	handleTurnStartReset()



func updateCardNameAndBasicInfo(isCreature:bool):
	subTypes = subTypeStr.split(" ")

	createEffectText()
	
	$Frontside/CardName/Label.text = cardName
	
	if isCreature:
		$Frontside/Resources/Panel/HBox/PowerLabel.text = "%d" % startingDamage
		$Frontside/Resources/Panel/HBox/HealthLabel.text = "%d" % startingHealth

func tempSetCardArt(new_art: Texture):
	$Frontside/Art.texture = new_art
	
func createEffectText():
	
	match cardType:
		CardTypes.CREATURE:
			cardTypeStr = "Creature"
		CardTypes.RITUAL:
			cardTypeStr = "Ritual"
		CardTypes.CHAMPION:
			cardTypeStr = "Champion"
	
	
	subTypeStr = ""
	for type in subTypes:
		subTypeStr += type
		subTypeStr += " "
	subTypeStr = subTypeStr.rstrip(" ")
	
	#################################### EFFECT TEXT
	var effectTexts := []
	
	#### CHECK FROM KEYWORDS HANDLER
	for keyword in getKeywords():
		effectTexts.append(keyword.id)
	
	
	#### CHECK ACTION NODES (CAST, BATTLE ART, and RITUAL NODES etc.)
	var actionHolderTexts:Array = actions.createActionText()
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
	
	
################################################

func basicSetup():
	#### SETUP FOR ALL ACTION SCRIPTS
	$Actions.setup(self)

	
	
func handleTurnStartReset():
	tempDamage = damage
	tempHealth = health
	


#### HANDLE CARD BEING PLAYED ON BOARD
func handleArrival():
	basicSetup()
	
	var params = SignalParams.new()
	params.sourceCard = self
	SignalBus.arrival.emit(params)
	handleTurnStartReset()
	updateCardVisuals()


func setInitialActionState():
	cardState = CardStates.BOARD
	statesPassive()
	
	#### ENEMY CARDS ATTACK BY DEFAULT
	if isEnemyCard: 
		#if not keywordHandler.hasShadow:
		if block_on_arrival:
			statesActive()

#endregion



#######################################################################################
#region ######################################### KEYWORD HANDLER STUFF

func getKeywords() -> Array:
	return $KeywordHandler.collectKeywords()
	
	
func hasKeyword(keyword:String) -> bool:
	for i in getKeywords():
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


## Adds keywords from an array of string values.
func replace_keywords(new_k:PackedStringArray):
	for string:String in new_k:
		addKeyword(string)

#endregion



#######################################################################################
#region ######################################### COUNTER NODE STUFF


#endregion



#######################################################################################
#region ######################################### EFFECT COUNTER STUFF

#### GET ALL EFFECTS -> USED BY hasEffect() AND OTHER STUFF
func getEffects() -> Array:
	var counters = []
	for e:EffectCounter in $Effects/Buff/Nodes.get_children():
		counters.append(e)
	for e:EffectCounter in $Effects/Debuff/Nodes.get_children():
		counters.append(e)
	return counters


#### GET EFFECTS, SEE IF ID MATCHES
func hasEffect(id:String):
	var counters = getEffects()
	for i in counters:
		if i.id == id:
			print(i.name)
			return true
	return false


func getEffect(id:String) -> CardEffect:
	var counters = getEffects()
	for i in counters:
		if i.id == id:
			return i
	return null


func addEffect(appliedEffect: CardEffect):
	effects.addEffect(appliedEffect)


## Increase or decrease the number of stacks on a given effect counter.
func changeEffectStacks(id:String, amount: int):
	if getEffect(id) is EffectCounter:
		var counter = getEffect(id).counter
		getEffect(id).counter += amount
	checkAndTerminateEffects()
	effects.updateEffectVisuals()


## Checks if any effect counters are at 0. If they are not permanent, remove them.
func checkAndTerminateEffects():
	for effect: EffectCounter in getEffects():
		if effect.counter < 1 and !effect.isPermanent:
			MyTools.createCombatLogPrintout(str(effect.id, ' was removed from ', MyTools.getFactionString(self), ' ', name), Color('DARK_SALMON'))
			removeEffect(effect)
	effects.updateEffectVisuals()


## Remove an effect.
func removeEffect(effect:EffectCounter):
	if effect in getEffects():
		if effect.is_inside_tree():
			effect.queue_free()


func clearEffects():
	for child in $Effects/Buff/Nodes.get_children():
		child.queue_free()
	for child in $Effects/Debuff/Nodes.get_children():
		child.queue_free()
	effects.updateEffectVisuals()

#endregion



#######################################################################################
#region ######################################## COLOR FETCHERS

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

#endregion

#######################################################################################

##############################################################################
#region ######################################## MOUSE INTERACTION
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
		faceUp()
	else:
		faceDown()

func faceUp():
	$Frontside.show()
	$Backside.hide()

func faceDown():
	$Frontside.hide()
	$Backside.show()

#endregion

#############################################################################
#region ######################################### HANDLE REST
#### ANIMATE = ROTATE CARD IMMEDIATELY
#### DON'T ANIMATE = PLAY ANIMATION ON DELAY? ->TO PLAY ATTACK ANIMATION FIRST
func restAndAnimate():
	isResting = true
	statesPassive()
	toggleAllowEnemyUse(true)
	CardAnimationQueue.queueAnimation(self, rotateRestingCard, 0.2)


func wake():
	isResting = false
	if checkAlive():
		CardAnimationQueue.queueAnimation(self, rotateRestingCard, 0.2)
	else:
		rotateRestingCard()

#endregion

##############################################################################
#region ########################################## STATE STUFF
func switchBlockingState():
	if actionState == CardActionStates.ACTIVE:
		statesPassive()
	elif actionState == CardActionStates.PASSIVE:
		statesActive()



func statesActive():
	actionState = CardActionStates.ACTIVE
	stateHandler.get_node("ActiveIcon").show()
	
	CardAnimationQueue.queueAnimation(self, animateBlockingState, 0.2)
	
	

func statesPassive():
	print(cardName, ' goes passive')
	actionState = CardActionStates.PASSIVE
	toggleActionStateIndicator(false)
	
	#### POSITION AS INDICATOR
	if checkAlive():
		CardAnimationQueue.queueAnimation(self, animateBlockingState, 0.2)



func vacateSlot():
	if mySlot:
		mySlot.toggleAvailable(true)
	mySlot = null



func statesHand():
	vacateSlot()
	cardState = CardStates.HAND
	if isEnemyCard:
		toggleEnemyStatus(true)
		toggleFrontSide(false)


func statesDiscard():
	cardState = CardStates.GRAVEYARD


func statesDeck():
	vacateSlot()
	cardState = CardStates.DECK


func statesBoard():
	cardState = CardStates.BOARD


func statesLimbo():
	cardState = CardStates.LIMBO



func toggleTraveling(enabled:bool):
	isTraveling = enabled
	if enabled:
		stateHandler.get_node("TravelingIcon").show()
	else:
		stateHandler.get_node("TravelingIcon").hide()


func toggleAllowEnemyUse(enabled:bool):
	allowEnemyUse = enabled

##################################

## Returns true is the card's action state is Active and false if it's not.
func checkCanBlock() -> bool:
	#assert(1==2,"where is this called")
	if actionState == CardActionStates.ACTIVE:
			return true
	return false

func checkCanAct() -> bool:
	if isEnemyCard:
		if not allowEnemyUse:
			return false
	
	if not checkAlive():
		return false
	
	if checkResting():
		return false
		
	if checkTraveling():
		return false
					
	return true



func checkResting() -> bool:
	return isResting


func checkTraveling() -> bool:
	return isTraveling


func checkAlive():
	return cardState == CardStates.BOARD


#### LIMBO means the CARD IS BETWEEN STATES -> for example, NEITHER IN Board OR Graveyard
func checkLimbo():
	return cardState == CardStates.LIMBO

	
#endregion

###############################################################################
#region #########################################  COMBAT STUFF




#### RETURNS THE INPUT DAMAGE, AND ADDS to it any of 
#### THIS CARD'S (Damage Taking card) DAMAGE-CHANGING EFFECTS
func takeDamage(amount:int):
	
	var damageTaken = getDamageToSelf(amount)
	
	#### DAMAGE IS DEALT
	tempHealth -= damageTaken
	var amountString := "%s %s takes %d damage" % [MyTools.getFactionString(self), self.cardName, amount]
	var color:Color = Color.DARK_SALMON
	MyTools.createCombatLogPrintout(amountString, color)
	
	#### DAMAGE_TAKEN SIGNAL IS EMITTED
	var signal_data = SignalParams.new()
	signal_data.amount = damageTaken
	signal_data.isEnemySide = isEnemyCard
	signal_data.sourceCard = self
	SignalBus.damage_taken.emit(signal_data)




## Returns damage taken by self after general modifiers.
func getDamageToSelf(amount:int) -> int:
	var damageTaken = amount
	## EFFECTS THAT CHANGE *ALL* DAMAGE TAKEN BY THIS CARD, INCLUDING INDIRECT. 
	## IF THIS IS TRUE, THE CARD WILL TAKE NO DAMAGE.
	var damageIgnored = false
	
			
	## DOOM
	if getEffect('Doom'):
		damageTaken += getEffect('Doom').counter
	
	#### ARMOR
	if hasEffect("Armor"):
		var armorStacks:int = getEffect("Armor").counter
		damageTaken -= armorStacks
		
	#### PROTECTION
	if hasEffect('Protection'):
		damageIgnored = true
		
	#### FIX DAMAGE
	
	if damageIgnored:
		damageTaken = 0
		
	if damageTaken < 0:
		damageTaken = 0
	
	return damageTaken
	
	
	
## Restores a card's health to its max value.
func heal():
	tempHealth = health



#### RETURNS THE TEMPORARY DAMAGE, AND ADDS to it any of 
#### THIS CARD'S (Damage Dealer) DAMAGE-CHANGING EFFECTS
func getCombatDamageToTarget(target:Card, isAttacker: bool):
	#### BASELINE
	var combatDamage:int = tempDamage
	
	
	
	if hasEffect('Rage') and not isAttacker:
		combatDamage += getEffect('Rage').counter
		
	if hasEffect('Terror') and isAttacker:
		combatDamage -= getEffect('Terror').counter
	
	#### END OF TARGETLESS DAMAGE CALCULATION
	if not target:
		return combatDamage
	
	
	#### FIX DAMAGE
	combatDamage = target.getDamageToSelf(combatDamage)
	
	return combatDamage



#### HANDLE CARD'S INTERNAL COMBAT STUFF (EXCEPT Damage Calculation)
func handleCombatActions(attacker:Card, defender:Card, waitingFunction:Callable):
	var waitTime = 1.5
	
	allowInteract = false
	if attacker == self:
		z_index = 10
		CardAnimationQueue.queueAnimation(self, playAttackAnimation, waitTime, waitingFunction)
	elif defender == self:
		z_index = 0
		waitTime = 1
		CardAnimationQueue.queueWait(waitTime)
		
	return waitTime



#### Self: who takes damage. Card -- the other guy.
func takeCombatDamage(card:Card, isAttacker: bool):
	
	var selfCombatDamage:int = getCombatDamageToTarget(card, !isAttacker)
	var enemyCombatDamage:int = card.getCombatDamageToTarget(self, isAttacker)
	
	#### CHECK IF THE ENEMY WOULD BE KILLED IN COMBAT WITH THIS CARD, AND EMIT SIGNAL.
	if selfCombatDamage >= card.tempHealth + selfCombatDamage:
		print('This cards can deal ', selfCombatDamage, ' damage and kill the foe ', card.cardName , 'with ', card.tempHealth, ' HP' )
		var params = SignalParams.new()
		params.sourceCard = self
		params.targetCard = card
		params.amount = selfCombatDamage
		SignalBus.emit_signal("killed_enemy", params)
			
	
	#### DEAL DAMAGE
	var damageTaken = enemyCombatDamage
	takeDamage(damageTaken)
				
	updateCardVisuals()
	#return damageTaken
	


func checkAndHandleCombatDeath(isAttacker:bool) -> bool:
	checkAndHandleDeathFromTempHealth()
	
	#### THIS CARD WAS DESTROYED
	if tempHealth <= 0:
		CardAnimationQueue.queueWait(1)
		return true
	
	#### THIS CARD SURVIVES		
	CardAnimationQueue.queueAnimation(self, returnToSlot, 0.2)
	
	#### SURVIVES, And IS ATTACKER	
	if isAttacker:
		#### REST, OR TRAVEL If Vanguard
		if hasKeyword('Vanguard'):
			toggleTraveling(true)
		else:
			restAndAnimate()

	$SFX/DefendSound.play()
	allowInteract = true
	
	var params = SignalParams.new()
	params.sourceCard = self
	SignalBus.survived.emit(params)
	return false
	
	

##CHECK IF DESTROYED
func checkAndHandleDeathFromTempHealth():
	if tempHealth <= 0:
		destroyAndAnimate()



###############################################################################
#### IF TOANIMATE == FALSE, then (Card is DEFENDER?) -> ANIMATION CALLED ELSEWHERE
#### IN ATTACK ANIMATION, TO BE SPECIFIC
func destroyAndAnimate():
	var params = SignalParams.new()
	params.sourceCard = self
	SignalBus.emit_signal("death", params)
	
	if hasEffect('Defy Death'):
		SignalBus.emit_signal("death_defied", params)
		SignalBus.emit_signal("survived", params)
		CardAnimationQueue.queueAnimation(self, returnToSlot, 0.2)
		tempHealth = health
		updateCardLabels()
		return
			
	
	statesLimbo()
	CardAnimationQueue.queueAnimation(self, playCardDestroyedAnimation, 2, handleEnterGraveyard)
	
	handleEnterGraveyard()
	
	

func handleEnterGraveyard():
	vacateSlot()
	
	if hasKeyword('Transient'):
		purge()
		return
	
	statesDiscard()
	resetCardAtStateChange()
	cardsManager.moveToDiscard(self, isEnemyCard)
	
	
	
func resetCardAtStateChange():
	handleTurnStartReset()
	clearEffects()
	
	wake()
	statesPassive()
	toggleTraveling(false)
	
	toggleManaCostIndicator(true)
	updateCardLabels()
	reset_shaders()
		

#endregion

##################################################################################
#region ######################################## VISUALS - HUD
func handleAttackingPortrait():
	if not checkAlive():
		return
	restAndAnimate()
	
	var params := SignalParams.new()
	params.sourceCard = self
	params.targetCard = null
	SignalBus.attacked.emit(params)
	
	

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
		if not isChampion:
			$Frontside/ManaCost.hide()
		else:
			$Frontside/ManaCost/ManaCostLabel.text = "%d" % tempHealth


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

#endregion

###############################################################################
#region ######################################## VISUALS - ANIMATIONS

#### LENGTH = 0.5 + 1 = 1.5 s
func playAttackAnimation():
	var defender:Card = battleSystem.currentDefendingCard
	
	var offset = Vector2(0,300)
	if isEnemyCard:
		offset = -offset
		
	var tween = create_tween()
	var attacking_position = defender.position + offset
	## The attacking card floats in front of the defending card.
	await tween.tween_property(self, 'position', attacking_position, 0.5)
	
	## The attacking card pounces on the defending card.
	if isEnemyCard:
		$BodyAnimations.play("EnemyAttack")
	else:
		$BodyAnimations.play("PlayerAttack")
	


func returnToSlot():
	if not checkAlive():
		return
	if not mySlot:   #### Removed from slot already?
		return
	
	var tween = create_tween()
	tween.tween_property(self, "position", mySlot.position, 0.2)
	CardAnimationQueue.queueInstant(self, animateBlockingState)
	
	
	
	
#### FOR RESTING	
func timeoutRestAnimation() -> void:
	if checkResting():
		CardAnimationQueue.queueAnimation(self, rotateRestingCard, 0.2)



func reset_visuals():
	$BodyAnimations.play("RESET")



func animatePlaceInSlot():
	var originalPos := position
	MyTools.moveCardTweening(self, originalPos, mySlot.position)


func animateBlockingState():
	var toBlock := (actionState == CardActionStates.ACTIVE)
	if not mySlot:
		return	
	var newPos = mySlot.position
	
	#### POSITION AS INDICATOR
	if toBlock:
		var activeOffset := -50
		if isEnemyCard:
			activeOffset *= -1
		newPos.y += activeOffset
		
	MyTools.moveCardTweening(self, position, newPos)



#### LENGTH = 2 seconds
func playCardDestroyedAnimation():
	if checkAlive():
		return
	
	## If a card was killed by an attack, it recoils backwards.
	var change_position = Vector2(0, 30)
	if isEnemyCard:
		change_position = -change_position
	var change_rotation = randf_range(-10.0, 10.0)
	
	var tween = create_tween()
	tween.tween_property(self, "position", position + change_position, 2).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "rotation_degrees", change_rotation, 0.2)
	
	$SFX/DeathSound.play()
	burnAwayShader()
	

#### LENGTH = 2 seconds, PARALLEL to playCardDestroyedAnimation()
func burnAwayShader():
	material = load("res://Resources/Shaders/destroy_card_material.tres")
	var tween = create_tween()
	tween.tween_method(set_shader_property.bind('percentage'), 1.0, 0.0, 2)
	
	
func set_shader_property(value:float, property:String):
	material.set_shader_parameter(property, value)
	

func reset_shaders():
	set_shader_property(1.0, 'percentage')
	
	
#################################################################################


func rotateRestingCard():
	var willRest = isResting
	
	var degreesGoal = 0
	if willRest:
		degreesGoal = 25
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation_degrees", degreesGoal, 0.2)
	


#### LENGTH = 1 + 1 = 2 s ?
func PlayRitualCastAnimation():
	var screen_center = Vector2(1050, 350)
	z_index = 999
	await MyTools.moveCardTweening(self, position, screen_center)
	faceUp()
	var tween = get_tree().create_tween()
	await tween.tween_property(self, "scale", Vector2(3.0, 3.0), 1)
	await get_tree().create_timer(1).timeout
	

func playAttackPortraitAnimation():
	var portraitPosition: Vector2 = gameBoard.getPortraitPosition(isEnemyCard)
	
	var tween = create_tween()
	tween.tween_property(self, "position", portraitPosition, 0.2)
	
	gameBoard.battleSystem.playerAttackedSE()
	gameBoard.shake_screen(10, 0.5)
	


#endregion

################################################################################
#region ############################################ VISUALS
#######################################################################

func updateCardVisuals():
	
	updateCardLabels()
	effects.updateEffectVisuals()
	
	if cardState == CardStates.HAND:
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
	if isChampion:
		$Frontside/ManaCost/ManaCostLabel.text = "%d" % tempHealth
	
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
		


	
func purge():
	queue_free()



func toggleCardName(enable:bool):
	$Frontside/CardName.visible = enable
#endregion

###############################################################################
#region #########################################UPGRADE FUNCTIONALITY
###########################################################

## Sets card stats, action node and keywords to alternative ones.
func change_upgrade_state(new_state:UpgradeStates):
	
	## Puts triggers in all actions nodes to sleep.
	setup_all_actions()
	
	match new_state:
		UpgradeStates.PATH_1:
			cardName = alt_card_name_1
			if alt_actions_node_1:
				actions = alt_actions_node_1
			if alt_keywords_1:
				$KeywordHandler.clearKeywords()
				replace_keywords(alt_keywords_1)
			$Frontside/Art.texture = alt_art_1
			damage = alt_damage_1
			health = alt_health_1
			manaCost = alt_mana_cost_1
		UpgradeStates.UNUPGRADED:
			damage = startingDamage
			health = startingHealth
		_:
			assert(1==2, 'Value out of bounds')
	actions.awakenTriggers()
	updateCardNameAndBasicInfo(cardType==CardTypes.CREATURE)


#endregion
