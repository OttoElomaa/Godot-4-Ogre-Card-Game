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
	if States.gameState == States.GameStates.ATTACK:
		
		if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
			if e.is_pressed():
				handlePlayerAttack()
				
	if States.gameState == States.GameStates.CAST:
		
		if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
			if e.is_pressed():
				handlePlayerCast()


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
		var target:Card = getCollidedObject(results[0])
		handlePlayerAttackCreature(target)
		return
	
	#### CHECK IF ENEMY PORTRAIT AT MOUSE POSITION
	results = main.fetchMouseOverObjects(COLLISION_MASK_ENEMY_PORTRAIT)
	if results.size() > 0:
		handlePlayerAttackEnemy()
		updateResourceLabels()
		return



func handlePlayerRitual(c:Card, target:Card) -> bool:
	
	#### GET CARD in SLOT
	if target:
		var success = c.ritualNode.activate(target)
		#if success:
			#c.destroyAndAnimate(true)
		return success
	
	#### IF CARD=NULL, TARGET ENEMY PORTRAIT
	else:
		handlePlayerAttackEnemy()
		updateResourceLabels()
		return true
	
	return false



func handlePlayerCast():
	print("Click - Player trying to cast")
	
	#### GET CARDS AT MOUSE POSITION
	var results = main.fetchMouseOverObjects(COLLISION_MASK_CARD)
	prints("Cards found for casting: ", results.size())
	
	for r in results:
		var target:Card = getCollidedObject(r)
		prints("Cast target card: ", target)
		if currentCastingCard.castNode.activate(target):
			currentCastingCard.restAndAnimate(true)
			currentCastingCard = null
			endCastState()
			return



func handlePlayerAttackEnemy():
	#### ENEMY HAS BLOCKERS, CAN'T ATTACK ENEMY
	if not cardsManager.getEnemyBlockers().is_empty():
		endAttackState()
		return
		
	#### ATTACK THE ENEMY
	var c = currentAttackingCard
	var combatDamage = c.getCombatDamage()
	enemyHealth -= combatDamage
	
	c.playAttackAnimation()
	c.restAndAnimate(false)
	endAttackState()
	c.countersNode.togglePhased(false)


#### BTW, PlayAttackAnimation CALLS THE CARD DESTROY COMMAND
func handleEnemyAttackPlayer(attackCard: Card):
	
	var c = attackCard
	var blockers:Array = cardsManager.getPlayerBlockers()
	var target:Card = null
	
	#### PLAYER HAS BLOCKERS, FIND KILLABLE BLOCKER
	for other in blockers:
		if c.checkHasLethal(other): #### HAS LETHAL DAMAGE -> Attack
			target = other
		elif c.hasSunder:			#### CAN SUNDER -> Attack
			target = other
	
	#### TARGET FOUND, ATTACK TARGET CARD
	if target:
		#### IF ATTACKER DESTROYED, NO ANIMATIONS
		c.playAttackAnimation()
		if not resolveAttack(c, target):
			c.restAndAnimate(false)
	
	#### NO BLOCKERS, ATTACK PLAYER
	elif blockers.is_empty():
		playerHealth -= c.getCombatDamage()
		c.playAttackAnimation()
		c.restAndAnimate(false)
		c.countersNode.togglePhased(false)
	


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
		attackCard.restAndAnimate(false)
	
	
	#### HANDLE ATTACKER COMBAT ARTS
	attackCard.battleArtNode.activate(targetCard)
	#### DEFENDER TOO RIGHT ????
	targetCard.battleArtNode.activate(attackCard) 
	
	attackCard.countersNode.togglePhased(false)
		
	#### HANDLE DESTROYING THE CARDS THAT TOOK LETHAL DAMAGE
	for c:Card in cardsToDestroy:
		if c == attackCard:
			c.destroyAndAnimate(false)
		else:
			c.destroyAndAnimate(true)
		
	return attackerDestroyed



func endAttackState():
	if States.gameState == States.GameStates.ATTACK:
		attackLineShown = false
		$AttackLine.hide()
		States.gameState = States.GameStates.PLAY
	
func endCastState():
	castLineShown = false
	$CastLine.hide()
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
	
