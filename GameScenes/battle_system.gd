extends Node2D




var main:GameBoard = null
var cardsManager:Node = null

@onready var attackLine := $AttackLine
@onready var castLine := $CastLine
var COLLISION_MASK_CARD := 1
var COLLISION_MASK_ENEMY_PORTRAIT := 4

var turnCount := 0
var playerMana := 0
var enemyMana := 0

var playerHealth := 20
var enemyHealth := 20

var attackLineShown: bool = false
var currentAttackingCard: Card = null

var castLineShown: bool = false
var currentCastingCard: Card = null




func _ready() -> void:
	
	turnCount += 1
	playerMana = turnCount
	enemyMana = turnCount
	#updateResourceLabels()
	
	
	
func updateResourceLabels():
	main.updateResourceLabels(playerHealth, playerMana, enemyHealth, enemyMana)



func _input(e: InputEvent) -> void:
	#### ONLY PROCESS ATTACK STATE HERE
	if States.gameState != States.GameStates.ATTACK:
		return
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		if e.is_pressed():
			handlePlayerAttack()


func _physics_process(delta: float) -> void:
	
	if attackLineShown:
		attackLine.points[1] = get_global_mouse_position()
	if castLineShown:
		castLine.points[1] = get_global_mouse_position()
	

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
	#### PLAY CARDS FROM HAND
	var enemyHandCards = cardsManager.getEnemyHandCards()
	for card:Card in enemyHandCards:
		if MyTools.checkNodeValidity(card):
			if card.manaCost <= enemyMana:
				var success = playEnemyCard(card)
				if success:
					enemyMana -= card.manaCost
	
	

func timeoutEnemyStartCombat() -> void:
	#### ATTACK WITH CARDS ON BOARD
	var enemyBoardCards = cardsManager.getEnemyBoardCards()
	for card:Card in enemyBoardCards:
		if not MyTools.checkNodeValidity(card):  #### CHECK IF VALID
			pass
		elif card.checkCanAct(): #### CAN IT ACT
			handleEnemyAttackPlayer(card)
			#currentAttackingCard = card

func playEnemyCard(card:Card):
	for slot:CardSlot in main.getEnemySlots():
		if slot.isAvailable:
			cardsManager.placeCardInSlot(card, slot)
			card.reparent(cardsManager.get_node("EnemyBoard"))
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

#############################################################################
#### PLAYER ATTACK FUNCTIONS

#### TURN ON PLAYER ATTACK MODE
func togglePlayerAttackMode(enable:bool, card:Card):
	
	if not MyTools.checkNodeValidity(card):
		return
	
	if card.checkCanAct():
		currentAttackingCard = card
		States.gameState = States.GameStates.ATTACK
		
		attackLineShown = enable
		$AttackLine.show()
		attackLine.points[0] = card.position



#### PROCESS ATTACK TARGET (ENEMY, OR ENEMY CARD)
func handlePlayerAttack():
	
	#### GET CARDS AT MOUSE POSITION
	var results = main.fetchMouseOverObjects(COLLISION_MASK_CARD)
	if results.size() > 0:
		handlePlayerAttackCreature(results)
		return
	
	#### CHECK IF ENEMY PORTRAIT AT MOUSE POSITION
	results = main.fetchMouseOverObjects(COLLISION_MASK_ENEMY_PORTRAIT)
	if results.size() > 0:
		handlePlayerAttackEnemy()
		updateResourceLabels()
		return


func handlePlayerAttackEnemy():
	#### ENEMY HAS BLOCKERS, CAN'T ATTACK ENEMY
	if cardsManager.getEnemyBlockers().size() > 0:
		endAttackState()
		return
	#### ATTACK THE ENEMY
	var c = currentAttackingCard
	enemyHealth -= c.damage
	c.playAttackAnimation()
	c.rest()
	endAttackState()


#### BTW, PlayAttackAnimation CALLS THE CARD DESTROY COMMAND
func handleEnemyAttackPlayer(attackCard: Card):
	
	var c = attackCard
		
	#### PLAYER HAS BLOCKERS, FIND KILLABLE BLOCKER
	var blockers:Array = cardsManager.getPlayerBlockers()
	var target:Card = null
	for other in blockers:
		if c.checkHasLethal(other):
			target = other
	
	#### TARGET FOUND, ATTACK TARGET CARD
	if target:
		#### IF ATTACKER DESTROYED, NO ANIMATIONS
		c.playAttackAnimation()
		if not resolveAttack(c, target):
			c.rest()
	
	#### NO BLOCKERS, ATTACK PLAYER
	elif blockers.is_empty():
		playerHealth -= c.damage
		c.playAttackAnimation()
		c.rest()
	


func handlePlayerAttackCreature(results:Array):
	
	var target:Card = getCollidedObject(results[0])
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
	currentAttackingCard.playAttackAnimation()
	endAttackState()
	resolveAttack(currentAttackingCard, target)
		

		

#### THIS FUNCTION PLAYS OUT THE COMBAT BETWEEN TWO CARDS, 
#### AFTER OTHER FUNCTIONS OKAYED THE COMBAT
func resolveAttack(attackCard:Card, targetCard:Card) -> bool:
	
	#### WHICH CARDS TOOK LETHAL DAMAGE?
	var cardsToDestroy := []
	if targetCard.takeDamageAndCheckLethal(attackCard):
		cardsToDestroy.append(targetCard)
	if attackCard.takeDamageAndCheckLethal(targetCard):
		cardsToDestroy.append(attackCard)
	
	#### DON'T REST-ANIMATE DESTROYED ATTACKER CARD
	var attackerDestroyed := false
	if attackCard in cardsToDestroy:
		attackerDestroyed = true
	else:
		attackCard.rest()
		
	#### HANDLE DESTROYING THE CARDS THAT TOOK LETHAL DAMAGE
	for c:Card in cardsToDestroy:
		c.mySlot.isAvailable = true
		#c.destroyCardOne()
		c.statesDestroy()
	
	#### PROCESS TARGET CARD'S STATUS
	if targetCard in cardsToDestroy:
		targetCard.destroyCardOne()
	
		
	return attackerDestroyed



func endAttackState():
	attackLineShown = false
	$AttackLine.hide()
	States.gameState = States.GameStates.PLAY
	
	

############################################################################

func getCollidedObject(result):
	return result.collider.get_parent()


func cardCastButtonPressed() -> void:
	
	currentCastingCard = main.actionMenuCard
	castLineShown = true
	States.gameState = States.GameStates.CAST
	
	$CastLine.show()
	castLine.points[0] = currentCastingCard.position
	main.toggleCardActionMenu(false, null)
	
