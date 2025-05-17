extends Node2D




var main:Node = null
var cardsManager:Node = null

@onready var attackLine := $AttackLine
var COLLISION_MASK_CARD := 1
var COLLISION_MASK_ENEMY_PORTRAIT := 4

var turnCount := 0
var playerMana := 0
var enemyMana := 0

var playerHealth := 20
var enemyHealth := 20

var attackLineShown: bool = false
var currentAttackingCard: Card = null




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
		#### NECESSARY CHECKS AND SET CURRENT ATTACKING CARD
		if not MyTools.checkNodeValidity(card):
			pass
		elif card.checkNotResting() and card.checkNotTraveling():
			#currentAttackingCard = card
			handleEnemyAttackPlayer(card)
				

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
	
	if card.checkNotResting() and card.checkNotTraveling():
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


func handleEnemyAttackPlayer(attackCard: Card):
	
	var c = attackCard
		
	#### PLAYER HAS BLOCKERS, ATTACK FIRST BLOCKER
	var blockers = cardsManager.getPlayerBlockers()
	if blockers.size() > 0:
		var target = blockers[0]
		#### IF ATTACKER DESTROYED, NO ANIMATIONS
		if resolveAttack(c, target):
			pass
		else:
			c.playAttackAnimation()
			c.rest()
	
	#### NO BLOCKERS, ATTACK PLAYER
	else:
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
	if not target.mySlot:
		if target != currentAttackingCard:
			endAttackState()
		return
	if main.checkSlotPlayer(target.mySlot):
		if target != currentAttackingCard:
			endAttackState()
		return
	
	#### VALID TARGET - RESOLVE ATTACK
	#prints("Player card targets enemy card: ", currentAttackingCard, target)
	if main.checkSlotEnemy(target.mySlot):
		if target.checkActive():
			currentAttackingCard.playAttackAnimation()
			endAttackState()
			resolveAttack(currentAttackingCard, target)
		

	#attackLineShown = false

	

#### THIS FUNCTION PLAYS OUT THE COMBAT BETWEEN TWO CARDS, 
#### AFTER OTHER FUNCTIONS OKAYED THE COMBAT
func resolveAttack(attackCard:Card, targetCard:Card) -> bool:
	
	#### WHICH CARDS TOOK LETHAL DAMAGE?
	var cardsToDestroy := []
	if targetCard.takeDamageAndCheckLethal(attackCard):
		cardsToDestroy.append(targetCard)
	if attackCard.takeDamageAndCheckLethal(targetCard):
		cardsToDestroy.append(attackCard)
	
	#### DON'T ANIMATE DESTROYED ATTACKER
	var attackerDestroyed := false
	if attackCard in cardsToDestroy:
		attackerDestroyed = true
	else:
		attackCard.rest()
		
	#### HANDLE DESTROYING THE CARDS THAT TOOK LETHAL DAMAGE
	for c:Card in cardsToDestroy:
		c.mySlot.isAvailable = true
		c.destroyCardOne()
	
	return attackerDestroyed



func endAttackState():
	attackLineShown = false
	$AttackLine.hide()
	States.gameState = States.GameStates.PLAY
	
	

############################################################################

func getCollidedObject(result):
	return result.collider.get_parent()
