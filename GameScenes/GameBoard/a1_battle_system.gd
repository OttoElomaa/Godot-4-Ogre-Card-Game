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
	GameInfo.enemy_turn = false
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
				



func _physics_process(delta: float) -> void:
	
	if playerAttackOngoing:
		var mousePos := get_global_mouse_position()
		attackLine.points[1] = mousePos
		damageCalculator.position = (mousePos + Vector2(100,-50)) * main.cameraMainBoard.zoom.x
		
	

#### AUTOMATIC TURN ORDER STUFF, ENEMY TURN STUFF
#######################################################################


#### PLAY ENEMY TURN, THEN AFTER TIMER WAIT, START PLAYER TURN
func _on_end_turn_button_pressed() -> void:
	switchBetweenPlayerEnemyTurns()
	
	#### THEN IF ENEMY TURN:
	if GameInfo.enemy_turn:
		cardsManager.startEnemyTurn()
		$EnemyStartCombatTimer.start()
		$EndEnemyTurnTimer.start()
		enemyPlayTurn()
	
	
func switchBetweenPlayerEnemyTurns():
	#### SWITCH TURN TYPE BETWEEN PLAYER <--> ENEMY
	GameInfo.enemy_turn = !GameInfo.enemy_turn
	
	if GameInfo.enemy_turn:
		print("Enemy turn start")
	else:
		print("Player turn start")
			
	SignalBus.turnStarted.emit(null)
	
	

func enemyPlayTurn() -> void:
	main.addLogMessage("Opponent turn!", Color.html("524634"))
	
	#### PLAY CARDS FROM HAND
	var enemyHandCards := cardsManager.getEnemyHandCards()
	
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
				await handleEnemyAttackPlayer(card)



func playEnemyCard(card:Card) -> bool:
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
	switchBetweenPlayerEnemyTurns()
	

#############################################################################
#### PLAYER ATTACK FUNCTIONS

#### TURN ON PLAYER ATTACK MODE
func togglePlayerAttackMode(enable:bool, card:Card) -> void:
	
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
		



func updateDamageCalculator(targetC:Card) -> void:
	
	var damageToDealLabel := $CanvasLayer/DamageCalculator/Panel/Margin/HBoxContainer/TargetDmgTakenLabel
	var damageToTakeLabel := $CanvasLayer/DamageCalculator/Panel2/Margin/HBoxContainer/AttackerDmgTakenLabel
	var extraDamage2Defender: int = 0
	var extraDamage2Attacker: int = 0
	
	var attacker:Card = currentAttackingCard
	if not attacker:
		return
	if targetC == attacker:
		return
	
	if targetC.getEffect('Doom'):
		extraDamage2Defender += targetC.getEffect('Doom').counter
	if attacker.getEffect('Doom'):
		extraDamage2Attacker += attacker.getEffect('Doom').counter
	
	if targetC.getEffect('Armor'):
		extraDamage2Defender -= targetC.getEffect('Armor').counter
	if attacker.getEffect('Armor'):
		extraDamage2Attacker -= attacker.getEffect('Armor').counter
	
	damageToDealLabel.text = "%d" % (attacker.getCombatDamageToTarget(attacker, true) + extraDamage2Defender) 
	damageToTakeLabel.text = "%d" % (targetC.getCombatDamageToTarget(targetC, false) + extraDamage2Attacker)
	


#### PROCESS ATTACK TARGET (ENEMY, OR ENEMY CARD)
func handlePlayerAttack() -> void:
	#### GET CARDS AT MOUSE POSITION
	var results = MyTools.fetchMouseOverObjects(COLLISION_MASK_CARD)
	if results.size() > 0:
		var target:Card = MyTools.getCollidedObject(results[0])
		handlePlayerAttackCreature(target)
		return
	
	#### CHECK IF ENEMY PORTRAIT AT MOUSE POSITION
	results = MyTools.fetchMouseOverObjects(COLLISION_MASK_ENEMY_PORTRAIT)
	if results.size() > 0:
		handlePlayerAttackEnemy()  #### ATTACK PORTRAIT
		updateResourceLabels()
		return


#### FOR PLAYING 'RITUAL' CARDS
func handlePlayerRitual(c:Card) -> bool:
	var success := false
	if playerMana < c.manaCost: #### CAN'T AFFORD, RETURN
		return success
	
	#### RESOLVE RITUAL IN CARD'S ACTION NODE (Could be TARGETED or TARGETLESS)
	success = await c.actions.handleRitual()
	
	if success:
		cardsManager.discardCard(c)
		playerMana -= c.manaCost
		cardsManager.updateHandCardsVisuals()
		updateResourceLabels()
	
	if success:
		main.addLogMessage("%s prayer is recited" % c.cardName, Color.WHITE)	
	
	return success

#func attack(attacker:Card, defender:Card):
#	SignalBus.attacked.emit(attacker, defender)
#	SignalBus.defended.emit(attacker, defender)
	

func cardCastButtonPressed() -> void:
	
	var c = main.actionMenuCard
	currentCastingCard = main.actionMenuCard
	
	if c:
		var castAction = c.actions.getCastAction()
		if castAction:   #### CAST ACTION WAS FOUND
			c.actions.handleCast()   #### IS IT TARGETED OR TARGETLESS
		
	
	
func handlePlayerAttackEnemy() -> void:
	#### ENEMY HAS BLOCKERS, CAN'T ATTACK ENEMY
	if not cardsManager.getEnemyBlockers().is_empty():
		endAttackState()
		return
		
	#### ATTACK THE ENEMY
	var c = currentAttackingCard
	var combatDamage = c.getCombatDamageToTarget(null, true)
	c.handleAttackingPortrait()
	enemyHealth -= combatDamage
	
	handlePortraitAttackPrintout(c, combatDamage, true)
	endAttackState()
	


#### BTW, PlayAttackAnimation CALLS THE CARD DESTROY COMMAND
func handleEnemyAttackPlayer(attackCard: Card) -> void:
	
	var c = attackCard
	var blockers:Array = cardsManager.getPlayerBlockers()
	var target:Card = null
	
	#### PLAYER HAS BLOCKERS, FIND KILLABLE BLOCKER
	for other in blockers:
		target = other
		
	#### TARGET FOUND, ATTACK TARGET CARD
	if target:
		#### IF ATTACKER DESTROYED, NO ANIMATIONS
		var success = await resolveAttack(c, target)
		c.restAndAnimate(false)
	
	#### NO BLOCKERS, ATTACK PLAYER
	elif blockers.is_empty():
		if not main.playerChampion():
			var damageToPlayer = c.getCombatDamageToTarget(null, true)
			await main.playAttackPortraitAnimation(c)
			main.changeHealth(-c.tempDamage, !c.isEnemyCard)
			handlePortraitAttackPrintout(attackCard, damageToPlayer, false)
			playerAttackedSE()
			main.shake_screen(10, 0.5)
			c.handleAttackingPortrait()
			await c.returnToSlot()
		else:
			var damageToChampion = c.getCombatDamageToTarget(main.playerChampion(), true)
			main.playerChampion().takeCombatDamage(c, true)
			handlePortraitAttackPrintout(attackCard, damageToChampion, false)
			c.handleAttackingPortrait()

func playerAttackedSE():
	$SE/SE_Player_Damaged.pitch_scale = 1.0 + randf_range(0.2, -0.2)
	## The bell gets lower-pitched the lower the HP gets.
	if playerHealth < 20:
		$SE/SE_Player_Damaged.pitch_scale += 0.02 * (playerHealth - 10)
	$SE/SE_Player_Damaged.play()

func handlePortraitAttackPrintout(attackCard:Card, damageAmount:int, targetIsEnemy:bool) -> void:
	var attackString := ""
	var targetName := ""
	if targetIsEnemy:
		targetName = "Top player (Enemy)"
	else:
		targetName = "Bottom player (Player)"
		
	attackString = "%s attacks %s!" % [attackCard.cardName, targetName]	
	main.addLogMessage(attackString, Color.WHITE)
	


func handlePlayerAttackCreature(target:Card) -> void:
	
	
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
	elif not target.allowInteract:
		end = true
		
	if end:
		if target != currentAttackingCard:
			endAttackState()
		return
	
	#### VALID TARGET - RESOLVE ATTACK
	await resolveAttack(currentAttackingCard, target)
		

		

#### THIS FUNCTION PLAYS OUT THE COMBAT BETWEEN TWO CARDS, 
#### AFTER OTHER FUNCTIONS OKAYED THE COMBAT
func resolveAttack(attackCard:Card, targetCard:Card) -> bool:
	endAttackState()
		
	#### HANDLE COMBAT ARTS AND OTHER ACTIONS
	targetCard.allowInteract = false
	await attackCard.handleCombatActions(attackCard, targetCard)
	targetCard.handleCombatActions(attackCard, targetCard)
	var params := SignalParams.new()
	params.sourceCard = attackCard
	params.targetCard = targetCard
	SignalBus.attacked.emit(params)
	
	var params2 := SignalParams.new()
	params2.sourceCard = targetCard
	params2.targetCard = attackCard
	SignalBus.defended.emit(params2)

	#### WHICH CARDS TOOK LETHAL DAMAGE?
	var damageTakenByTarget = targetCard.takeCombatDamage(attackCard, true)
	var damageTakenByAttacker = attackCard.takeCombatDamage(targetCard, false)

	#### CHECK IF EITHER CARD WAS DESTROYED
	var attackerDestroyed = attackCard.checkAndHandleCombatDeath(true)
	var targetDestroyed = targetCard.checkAndHandleCombatDeath(false)
	
	
	
	
	#### COMBAT LOG STUFF ##################################
	var attackerString = "%s attacks %s!" % [attackCard.cardName, targetCard.cardName]
	main.addLogMessage(attackerString, Color.WHITE)	
	
	var targetHurtString = "%s %s " % [MyTools.getFactionString(targetCard), targetCard.cardName]
	if targetDestroyed:
		targetHurtString += "was destroyed"
	main.addLogMessage(targetHurtString, targetCard.hurtColor)	
	
	var attackerHurtString = "%s %s " % [MyTools.getFactionString(attackCard), attackCard.cardName]
	if attackerDestroyed:
		attackerHurtString += "was destroyed"
	main.addLogMessage(attackerHurtString, attackCard.hurtColor)	
	
	
	#### RETURN WHETHER ATTACKER IS DESTROYED -> WHY?
	return attackerDestroyed



func endAttackState() -> void:
	if States.gameState == States.GameStates.ATTACK:
		togglePlayerAttackMode(false, null)
	




	
