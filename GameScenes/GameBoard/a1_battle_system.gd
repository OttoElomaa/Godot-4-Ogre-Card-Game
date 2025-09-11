extends Node2D
class_name  BattleSystem



var main:GameBoard = null
var cardsManager:CardsManager = null

@onready var attackLine := $AttackLine
@onready var damageCalculator := $CanvasLayer/DamageCalculator

var COLLISION_MASK_CARD := 1
var COLLISION_MASK_ENEMY_PORTRAIT := 4

var turnCount := 0
var playerMana := 0
var enemyMana := 0

var playerHealth := 20
var enemyHealth := 20

var playerAttackOngoing: bool = false
var currentAttackingCard: Card = null

var castLineShown: bool = false
var currentCastingCard: Card = null




func _ready() -> void:
	
	turnCount += 1
	playerMana = turnCount
	enemyMana = turnCount
	#updateResourceLabels()
	
	togglePlayerAttackMode(false, null)
	
	
	
func updateResourceLabels():
	main.updateResourceLabels(playerHealth, playerMana, enemyHealth, enemyMana)



func _input(e: InputEvent) -> void:
	#### ONLY PROCESS ATTACK STATE HERE
	if States.gameState == States.GameStates.ATTACK:
		
		if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
			if e.is_pressed():
				handlePlayerAttack()
				
	#if States.gameState == States.GameStates.CAST:
		
		#if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
			#if e.is_pressed():
				#handlePlayerCastTargeting()


func _physics_process(delta: float) -> void:
	
	if playerAttackOngoing:
		var mousePos := get_global_mouse_position()
		attackLine.points[1] = mousePos
		damageCalculator.position = (mousePos + Vector2(100,-50)) * main.cameraMainBoard.zoom.x
		
	#if castLineShown:
		#castLine.points[1] = mousePos
	

#######################################################################

func _on_end_turn_button_pressed() -> void:
	passTurn()
	
	
#### PLAY ENEMY TURN, THEN AFTER TIMER WAIT, START PLAYER TURN
func passTurn():
	cardsManager.startEnemyTurn()
	#cardsManager.wakeEnemyCards()
	$EnemyStartCombatTimer.start()
	$EndEnemyTurnTimer.start()
	enemyPlayTurn()
	


func enemyPlayTurn():
	
	main.addLogMessage("Opponent turn!", Color.html("524634"))
	
	#### PLAY CARDS FROM HAND
	var enemyHandCards = cardsManager.getEnemyHandCards()
	
	
	for card:Card in enemyHandCards:
		if MyTools.checkNodeValidity(card):
			if card.manaCost <= enemyMana and not card.isRitual:
				var success = playEnemyCard(card)
				if success:
					enemyMana -= card.manaCost
	
	

func timeoutEnemyStartCombat() -> void:
	#### ATTACK WITH CARDS ON BOARD
	var enemyBoardCards = cardsManager.getEnemyBoardCards()
	#### RUN MULTIPLE ROUNDS SO All enemy cards have TIME TO REACT if another enemy CARD DOES SOMETHING
	for i in range(3):
		for card:Card in enemyBoardCards:
			
			if not MyTools.checkNodeValidity(card):  #### CHECK IF VALID
				pass
			elif card.checkCanAct(): #### CAN IT ACT
				handleEnemyAttackPlayer(card)
				#currentAttackingCard = card



func playEnemyCard(card:Card):
	for slot:CardSlot in main.getEnemySlots():
		if slot.isAvailable and card.manaCost <= enemyMana:
			
			cardsManager.handlePlaceCardInSlot(card, slot)
			return true
	return false


#### START PLAYER'S TURN AFTER ENEMY ACTION
func timeoutEndEnemyTurn() -> void:
	turnCount += 1
	playerMana = turnCount
	enemyMana = turnCount
	updateResourceLabels()
	
	main.updateUi(turnCount)
	cardsManager.startPlayerTurn()
	
	main.addLogMessage("Player turn!", Color.html("524634"))

#############################################################################
#### PLAYER ATTACK FUNCTIONS

#### TURN ON PLAYER ATTACK MODE
func togglePlayerAttackMode(enable:bool, card:Card):
	
	#### TURN IT OFF
	if not enable:
		currentAttackingCard = null
		States.statesPlay()
		
		playerAttackOngoing = enable
		$AttackLine.hide()
		damageCalculator.hide()
		return
	
	#### DO NOTHING
	if not MyTools.checkNodeValidity(card):
		return
	
	#### TURN IT ON
	if card.checkCanAct():
		currentAttackingCard = card
		States.gameState = States.GameStates.ATTACK
		
		playerAttackOngoing = enable
		$AttackLine.show()
		attackLine.points[0] = card.position
		damageCalculator.show()


func updateDamageCalculator(targetC:Card):
	var damageToDealLabel := $CanvasLayer/DamageCalculator/Panel/Margin/HBoxContainer/TargetDmgTakenLabel
	var damageToTakeLabel := $CanvasLayer/DamageCalculator/Panel2/Margin/HBoxContainer/AttackerDmgTakenLabel
	
	var attacker:Card = currentAttackingCard
	if not attacker:
		return
	if targetC == attacker:
		return
		
	damageToDealLabel.text = "%d" % attacker.getCombatDamageToTarget(targetC)
	damageToTakeLabel.text = "%d" % targetC.getCombatDamageToTarget(attacker)
	


#### PROCESS ATTACK TARGET (ENEMY, OR ENEMY CARD)
func handlePlayerAttack():
	
	#### GET CARDS AT MOUSE POSITION
	var results = MyTools.fetchMouseOverObjects(COLLISION_MASK_CARD)
	if results.size() > 0:
		var target:Card = MyTools.getCollidedObject(results[0])
		handlePlayerAttackCreature(target)
		return
	
	#### CHECK IF ENEMY PORTRAIT AT MOUSE POSITION
	results = MyTools.fetchMouseOverObjects(COLLISION_MASK_ENEMY_PORTRAIT)
	if results.size() > 0:
		handlePlayerAttackEnemy()
		updateResourceLabels()
		return


#### FOR PLAYING 'RITUAL' CARDS
func handlePlayerRitual(c:Card, target:Card) -> bool:
	var success := false
	if playerMana < c.manaCost: #### CAN'T AFFORD, RETURN
		return success
	
	#### RESOLVE RITUAL IN CARD'S ACTION NODE (Could be TARGETED or TARGETLESS)
	success = c.actions.handleRitual()
	
	if success:
		cardsManager.discardCard(c)
		playerMana -= c.manaCost
		cardsManager.updateHandCardsVisuals()
		updateResourceLabels()
	
	if success:
		main.addLogMessage("%s prayer is recited" % c.cardName, Color.WHITE)	
	
	return success



func cardCastButtonPressed() -> void:
	
	var c = main.actionMenuCard
	currentCastingCard = main.actionMenuCard
	
	if c:
		var castAction = c.actions.getCastAction()
		if castAction:   #### CAST ACTION WAS FOUND
			c.actions.handleCast()   #### IS IT TARGETED OR TARGETLESS
			
	
	
func handlePlayerAttackEnemy():
	#### ENEMY HAS BLOCKERS, CAN'T ATTACK ENEMY
	if not cardsManager.getEnemyBlockers().is_empty():
		endAttackState()
		return
		
	#### ATTACK THE ENEMY
	var c = currentAttackingCard
	var combatDamage = c.getCombatDamageToTarget(null)
	
	handlePortraitAttackPrintout(c, combatDamage, true)
	
	
	enemyHealth -= combatDamage
	
	c.handleAttackingPortrait()
	endAttackState()
	


#### BTW, PlayAttackAnimation CALLS THE CARD DESTROY COMMAND
func handleEnemyAttackPlayer(attackCard: Card):
	
	var c = attackCard
	var blockers:Array = cardsManager.getPlayerBlockers()
	var target:Card = null
	
	#### PLAYER HAS BLOCKERS, FIND KILLABLE BLOCKER
	for other in blockers:
		target = other
		
	
	#### TARGET FOUND, ATTACK TARGET CARD
	if target:
		#### IF ATTACKER DESTROYED, NO ANIMATIONS
		var success = resolveAttack(c, target)
			#c.restAndAnimate(false)
	
	#### NO BLOCKERS, ATTACK PLAYER
	elif blockers.is_empty():
		var damageToPlayer = c.getCombatDamageToTarget(null)
		playerHealth -= damageToPlayer
		handlePortraitAttackPrintout(attackCard, damageToPlayer, false)
		c.handleAttackingPortrait()
	
	

func handlePortraitAttackPrintout(attackCard:Card, damageAmount:int, targetIsEnemy:bool):
	var attackString := ""
	var targetName := ""
	if targetIsEnemy:
		targetName = "Top player (Enemy)"
	else:
		targetName = "Bottom player (Player)"
		
	attackString = "%s attacks %s!" % [attackCard.cardName, targetName]	
	main.addLogMessage(attackString, Color.WHITE)
	
	var amountString := "%s takes %d damage" % [targetName, damageAmount]
	var color:Color = Color.DARK_SALMON
	main.addLogMessage(amountString, color)

func handlePlayerAttackCreature(target:Card):
	
	
	#### INVALID TARGET - END TARGETING ANYWAY
	if not MyTools.checkNodeValidity(target):
		endAttackState()
		return
		
	#### DON'T END TARGETING if it registers CLICKING ON SAME ATTACKING CARD ITSELF
	var end := false
	if not target.mySlot:
		end = true
	elif not main.checkSlotEnemy(target.mySlot):
		end = true
	elif not target.checkCanBlock():
		end = true
		
	if end:
		if target != currentAttackingCard:
			endAttackState()
		return
	
	#### VALID TARGET - RESOLVE ATTACK
	resolveAttack(currentAttackingCard, target)
		

		

#### THIS FUNCTION PLAYS OUT THE COMBAT BETWEEN TWO CARDS, 
#### AFTER OTHER FUNCTIONS OKAYED THE COMBAT
func resolveAttack(attackCard:Card, targetCard:Card) -> bool:
	#### WHICH CARDS TOOK LETHAL DAMAGE?
	var damageTakenByTarget = targetCard.takeCombatDamage(attackCard)
	var damageTakenByAttacker = attackCard.takeCombatDamage(targetCard)
		
	#### HANDLE COMBAT ARTS AND OTHER ACTIONS
	attackCard.handleCombatActions(true, targetCard)
	targetCard.handleCombatActions(false, attackCard)
	
	#### CHECK IF EITHER CARD WAS DESTROYED
	var attackerDestroyed = attackCard.checkAndHandleCombatDeath(true)
	var targetDestroyed = targetCard.checkAndHandleCombatDeath(false)
	
	endAttackState()
	
	
	#### COMBAT LOG STUFF ##################################
	var attackerString = "%s attacks %s!" % [attackCard.cardName, targetCard.cardName]
	main.addLogMessage(attackerString, Color.WHITE)	
	
	var targetHurtString = "%s takes %d damage" % [targetCard.cardName, damageTakenByTarget]
	if targetDestroyed:
		targetHurtString += " - Destroyed"
	main.addLogMessage(targetHurtString, targetCard.hurtColor)	
	
	var attackerHurtString = "%s takes %d damage" % [attackCard.cardName, damageTakenByAttacker]
	if attackerDestroyed:
		attackerHurtString += " - Destroyed"
	main.addLogMessage(attackerHurtString, attackCard.hurtColor)	
	
	
	#### RETURN WHETHER ATTACKER IS DESTROYED -> WHY?
	return attackerDestroyed



func endAttackState():
	if States.gameState == States.GameStates.ATTACK:
		togglePlayerAttackMode(false, null)
	
#func endCastState():
	#castLineShown = false
	#$CastLine.hide()
	#States.gameState = States.GameStates.PLAY	

############################################################################

#func getCollidedObject(result):
	#return result.collider.get_parent()



	
