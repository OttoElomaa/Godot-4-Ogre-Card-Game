extends Node2D
class_name  BattleSystem



var main:GameBoard = null
var cardsManager:CardsManager = null

@onready var attackLine := $AttackLine
@onready var damageCalculator := $CanvasLayer/DamageCalculator

var COLLISION_MASK_CARD := 1
var COLLISION_MASK_ENEMY_PORTRAIT := 4


#### STATE MANAGEMENT
var playerAttackOngoing: bool = false
var currentAttackingCard: Card = null
var currentDefendingCard: Card = null

var castLineShown: bool = false
var currentCastingCard: Card = null

#### ENEMY AI
var enemyChargeTarget: Card = null


var enemyBoardCards:Array:
	get:
		return cardsManager.getEnemyBoardCards()

var playerBoardCards:Array:
	get:
		return cardsManager.getPlayerBoardCards()


func _ready() -> void:
	GameInfo.enemy_turn = false
	togglePlayerAttackMode(false, null)
	


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
	if not GameInfo.enemy_turn:
		switchBetweenPlayerEnemyTurns()
	
	#### THEN IF ENEMY TURN:
	if GameInfo.enemy_turn:
		cardsManager.startEnemyTurn()
		await timeoutEnemyStartCombat()
		
	
	
func switchBetweenPlayerEnemyTurns():
	var signalParams = SignalParams.new()
	signalParams.isEnemySide = GameInfo.enemy_turn
	SignalBus.turnEnded.emit(signalParams)
	
	#### SWITCH TURN TYPE BETWEEN PLAYER <--> ENEMY
	GameInfo.enemy_turn = !GameInfo.enemy_turn
	
	#### AFTER THE SWITCH...
	#### IF ENEMY TURN STARTING
	if GameInfo.enemy_turn:
		
		GameInfo.enemyManaIncome += 1
		GameInfo.enemyMana = GameInfo.enemyManaIncome
		
		main.addLogMessage("Enemy turn!", Color.html("524634"))
		print("Enemy turn start")
		
	#### IF PLAYER TURN STARTING
	else:
		GameInfo.playerManaIncome += 1
		GameInfo.playerMana = GameInfo.playerManaIncome
		GameInfo.turnCount += 1
		
		main.addLogMessage("Player turn!", Color.html("524634"))
		print("Player turn start")
		
	main.updateResourceLabels()
	main.updateUi(GameInfo.turnCount)
	cardsManager.startPlayerTurn()
	
	signalParams.isEnemySide = GameInfo.enemy_turn
	SignalBus.turnStarted.emit(signalParams)
	
	

func timeoutEnemyStartCombat() -> void:
	enemyChargeTarget = null
	
	#### TANK CARDS DO NOT ACT ON THEIR TURN.
	### IF THERE ARE NO BLOCKING CARDS, THE STRONGEST ENEMY CARDS ARE SET TO BLOCK.
	for card:Card in enemyBoardCards:
		card.statesPassive()
		if card.action_mode == card.actionMode.TANK:
			card.statesActive()
	
	enemyActionsBeforeAttacking()	
	


func enemyActionsBeforeAttacking():
	var AI_Personality = main.AI_personality
	
	#### Perform actions in an order based on AI Personality.
	match AI_Personality:
		main.AI_personalities.COMMANDER:
			await enemySummonCreatures()
			await enemyPlayRituals()
			await decide_blockers()
			await enemyHandleCasters()
			enemyAttackersWaiter()
			
		main.AI_personalities.WIZARD:
			if cardsManager.getEnemyBlockers().is_empty():
				await enemySummonCreatures()
				await decide_blockers()
			await enemyPlayRituals()
			await enemyHandleCasters()
			enemyAttackersWaiter()
			
		main.AI_personalities.SPECIALIST:
			await enemyHandleCasters()
			await enemySummonCreatures()
			await enemyPlayRituals()
			await decide_blockers()
			enemyAttackersWaiter()



func enemyActionsAfterAttacking():
	var AI_Personality = main.AI_personality
	
	#### Perform actions in an order based on AI Personality.
	match AI_Personality:
	
		main.AI_personalities.WIZARD:
			await enemySummonCreatures()
			await decide_blockers()

	endEnemyTurn()




## Enemy summons creatures.
func enemySummonCreatures() -> void:
	main.addLogMessage("Opponent turn!", Color.html("524634"))
	
	#### PLAY CARDS FROM HAND
	var enemyHandCards := cardsManager.getEnemyHandCards()
	
	for card:Card in enemyHandCards:
		if MyTools.validateNodeNotLimbo(card):
			if card.manaCost <= GameInfo.enemyMana:
				if not card.isRitual:
					var success = playEnemyCard(card)
	await CardAnimationQueue.checkAndWaitQueueEmpty()
	return
					
					

func enemyPlayRituals() -> void:
	var enemyHandCards := cardsManager.getEnemyHandCards()
	
	for card:Card in enemyHandCards:
		if MyTools.validateNodeNotLimbo(card):
			if card.isRitual:
				if card.manaCost <= GameInfo.enemyMana:
					handlePlayerRitual(card)
					
	await CardAnimationQueue.checkAndWaitQueueEmpty()
	return



## Current algorithm -- half as many creatures need to be set as blockers as the player has on board. 
## If there are not enough TANKS, sets other cards instead, prioritizing strongest ones.
func decide_blockers():
	if enemyBoardCards.is_empty():
		return
	
	var blockers = MyTools.findValidNodesInArray(enemyBoardCards)
	var playerCardsAmount := playerBoardCards.size()
	
	blockers = CardChecks.sort_by_strongest(blockers)
	var projected_number_of_blockers = floor(playerCardsAmount / 2.0)
	
	if playerCardsAmount > 1:
		if projected_number_of_blockers < 1:
			projected_number_of_blockers = 1
	if projected_number_of_blockers > blockers.size():
		projected_number_of_blockers = blockers.size()
	
	for i in range(projected_number_of_blockers):
		var blocker:Card = blockers.front()
		if blocker.has_method('statesActive'):
			blocker.statesActive()
					
	await CardAnimationQueue.checkAndWaitQueueEmpty()
	return



func enemyHandleCasters():
	var enemyCasters = CardChecks.getCastersInList(enemyBoardCards)
	for card:Card in enemyCasters:
		await handleEnemyCast(card)
		
	await CardAnimationQueue.checkAndWaitQueueEmpty()
	return


func handleEnemyCast(castingCard:Card):
	castingCard.toggleAllowEnemyUse(false)
	if castingCard.actions.getCastAction():
		await castingCard.actions.handleCast()
	
	castingCard.toggleAllowEnemyUse(true)
	return



#### EACH ATTACKER CALLS THIS TO CONTINUE ENEMY COMBAT		
### ATTACKERS ATTACK OR CAST STARTING FROM THE PRIORITIZED/STRONGEST ONES.
func enemyAttackersWaiter():
	var enemyAttackers:Array = CardChecks.getAttackersInList(enemyBoardCards)
	var enemyWillingAttackers := getWillingEnemyAttackers(enemyAttackers)
	
	print("Waiter: %d Attackers found. %d are Willing." % [enemyAttackers.size(),enemyWillingAttackers.size()] )
	
	#### ENEMY ATTACKERS FOUND, CONTINUE COMBAT
	if not enemyWillingAttackers.is_empty():
		var card:Card = enemyWillingAttackers[0]
		print("Waiter: %s Attacks!" % card.cardName)
		handleEnemyAttackPlayer(card)
		card.toggleAllowEnemyUse(false)
		return
			
	#### END ENEMY COMBAT
	await CardAnimationQueue.checkAndWaitQueueEmpty()
	print("Waiter: Enemy Combat Ends!")
	enemyActionsAfterAttacking()



func playEnemyCard(card:Card) -> bool:
	for slot:CardSlot in main.getEnemySlots():
		if slot.isAvailable and card.manaCost <= GameInfo.enemyMana:
			cardsManager.handlePlaceCardInSlot(card, slot)
			return true
	return false



#### START PLAYER'S TURN AFTER ENEMY ACTION
func endEnemyTurn() -> void:
	await CardAnimationQueue.checkAndWaitQueueEmpty()
	switchBetweenPlayerEnemyTurns()
	


#############################################################################
#region ### PLAYER ATTACK FUNCTIONS

#### TURN ON PLAYER ATTACK MODE
func togglePlayerAttackMode(enable:bool, card:Card) -> void:
	
	#### TURN IT OFF
	if not enable:
		#currentAttackingCard = null
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
		



func updateDamageCalculator(targetC:Card) -> void:
	
	var damageToDealLabel := $CanvasLayer/DamageCalculator/Panel/Margin/HBoxContainer/TargetDmgTakenLabel
	var damageToTakeLabel := $CanvasLayer/DamageCalculator/Panel2/Margin/HBoxContainer/AttackerDmgTakenLabel
	
	var attacker:Card = currentAttackingCard
	if not attacker:
		return
	if targetC == attacker:
		return

	if not targetC:
		damageToDealLabel.text = "%d" % (attacker.getCombatDamageToTarget(null, true)) 
		damageToTakeLabel.text = "0"
		return

	damageToDealLabel.text = "%d" % (attacker.getCombatDamageToTarget(targetC, true)) 
	damageToTakeLabel.text = "%d" % (targetC.getCombatDamageToTarget(attacker, false))
	


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
		return


#### ATTACK ENEMY PORTRAIT
func handlePlayerAttackEnemy() -> void:
	#### ENEMY HAS BLOCKERS, CAN'T ATTACK ENEMY
	if not cardsManager.getEnemyBlockers().is_empty():
		endAttackState()
		return
		
	#### ATTACK THE ENEMY
	var c = currentAttackingCard
	var combatDamage = c.getCombatDamageToTarget(null, true)
	endAttackState()
	
	#### QUEUE THE ATTACK ANIMATIONS, THEN TELL RESPONSE QUEUE TO PLAY DEFENSE ANIMATIONS
	CardAnimationQueue.queueAnimation(c, c.animateAttackPortrait)
	CardAnimationQueue.queueFunction(CardAnimationQueue.startResponseQueue)
	CardAnimationQueue.queueAnimation(c, c.animateReturnToSlot)  
	CardAnimationQueue.queueAnimation(c, c.restAndAnimate)
	
	main.changeHealth(-combatDamage, !c.isEnemyCard)
	main.updateResourceLabels()
	handlePortraitAttackPrintout(c, combatDamage, true)
	main.shake_screen(10, 0.5)
	c.handleAttackingPortrait()
	


func handlePlayerAttackCreature(target:Card) -> void:
	#### INVALID TARGET - END TARGETING ANYWAY
	if not MyTools.checkNodeValidity(target):
		endAttackState()
		return
	if not target.checkAlive():
		endAttackState()
		return
		
	#### DON'T END TARGETING if it registers CLICKING ON SAME ATTACKING CARD ITSELF
	var end := false
	if not target.mySlot:
		print('Is not in slot!')
		end = true
	elif not main.checkSlotEnemy(target.mySlot):
		print('Is not an enemy!')
		end = true
#### DUMMIED CODE: ALLOWS TARGETING PASSIVES IS THERE ARE NO BLOCKERS.
#	elif not cardsManager.getEnemyBlockers().is_empty() and not target.checkCanBlock():
#		end = true
#### CANNOT TARGET PASSIVES AT ALL.
	elif not target.checkCanBlock():
		print('Is passive!')
		end = true
	elif not target.allowInteract:
		print('Already fighting!')
		end = true
		
	if end:
		if target != currentAttackingCard:
			print('Cannot attack self!')
			endAttackState()
		return
	
	#### VALID TARGET - RESOLVE ATTACK
	resolveAttack(currentAttackingCard, target)
		


#### THIS FUNCTION PLAYS OUT THE COMBAT BETWEEN TWO CARDS, 
#### AFTER OTHER FUNCTIONS OKAYED THE COMBAT
func resolveAttack(attackCard:Card, targetCard:Card):
	attackCard.isAttacking = true
	targetCard.isAttacking = false
	
	currentAttackingCard = attackCard
	currentDefendingCard = targetCard
	endAttackState()
		
	#### HANDLE COMBAT ARTS AND OTHER ACTIONS
	targetCard.allowInteract = false
	attackCard.handleCombatActions(attackCard, targetCard, resolveAttackTwo )
	targetCard.handleCombatActions(attackCard, targetCard, doNothing)
	
	
	
func resolveAttackTwo():
	CardAnimationQueue.queueFunction(CardAnimationQueue.startResponseQueue)
	
	var attackCard:Card = currentAttackingCard
	var targetCard: Card = currentDefendingCard
	
	#### WHICH CARDS TOOK LETHAL DAMAGE?
	var damageTakenByTarget = targetCard.takeCombatDamage(attackCard, false)
	if targetCard.checkCanRetaliate():
		var damageTakenByAttacker = attackCard.takeCombatDamage(targetCard, true)
	
	#### COMBAT LOG STUFF ##################################
	var attackerString = "%s attacks %s!" % [attackCard.cardName, targetCard.cardName]
	main.addLogMessage(attackerString, Color.WHITE)	
	
	#### EMITTING SIGNALS OF A COMPLETED COMBAT.
	var params := SignalParams.new()
	params.sourceCard = attackCard
	params.targetCard = targetCard
	SignalBus.attacked.emit(params)
	
	var params2 := SignalParams.new()
	params2.sourceCard = targetCard
	params2.targetCard = attackCard
	SignalBus.defended.emit(params2)
	
	targetCard.handleCombatSurvival(false)
	await attackCard.handleCombatSurvival(true)
	
	attackCard.isAttacking = false
	targetCard.isAttacking = false
	attackCard.toggleAllowEnemyUse(true)
	
	if attackCard.isEnemyCard:
		enemyAttackersWaiter()  #### CALL IN NEXT ATTACKER
	
	

func endAttackState() -> void:
	if States.gameState == States.GameStates.ATTACK:
		togglePlayerAttackMode(false, null)
	


#### FOR PLAYING 'RITUAL' CARDS
func handlePlayerRitual(c:Card) -> bool:
	var success := false
	if !c.isEnemyCard:
		if GameInfo.playerMana < c.manaCost: #### CAN'T AFFORD, RETURN
			return success
	
	#### RESOLVE RITUAL IN CARD'S ACTION NODE (Could be TARGETED or TARGETLESS)
	success = await c.actions.handleRitual()
	
	if success:
		cardsManager.discardCard(c)
		if !c.isEnemyCard:
			GameInfo.playerMana -= c.manaCost
		else:
			GameInfo.enemyMana -= c.manaCost
		cardsManager.updateHandCardsVisuals()
		main.updateResourceLabels()
	
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
		
	
	

	
#endregion

#region ### ENEMY ATTACKER AI
func getWillingEnemyAttackers(initialAttackers:Array) -> Array:
	var willingAttackers := []
	
	if cardsManager.getPlayerBlockers().is_empty():
		return initialAttackers
	
	var killableBlockers = getKillablePlayerBlockers()
	if killableBlockers.is_empty():
		return willingAttackers
	
	for card:Card in initialAttackers:
		if card.checkAlive() and card.checkCanAct():
				willingAttackers.append(card)
				
	return willingAttackers



func getKillablePlayerBlockers() -> Array:
	var blockers:Array = cardsManager.getPlayerBlockers()
	blockers = remove_unkillable_by_charge(blockers)
	
	return blockers


#### BTW, AnimateAttack CALLS THE CARD DESTROY COMMAND
func handleEnemyAttackPlayer(attackCard: Card) -> void:

	var c = attackCard
	if not MyTools.checkNodeValidity(c):
		return
	
	var blockers:Array = getKillablePlayerBlockers()
	var target:Card = null
	var action_modes = attackCard.actionMode

	
	#### PLAYER HAS BLOCKERS, FIND KILLABLE BLOCKER
	if not blockers.is_empty():
		blockers = CardChecks.sort_by_weakest(blockers)
		
		#### STEP 1 - CHECK IF THIS CARD CAN KILL AN ENEMY BY ITSELF.
		if not c.fearless:  #### FEARLESS WILL SACRIFICE ITSELF TO KILL
			blockers = remove_individually_unkillable(attackCard, blockers)
		
		#### STEP 1.1 ENEMY FOUND
		if not blockers.is_empty():
			target = blockers.front()
			
			#### CASE 1 - IF ATTACKER DESTROYED, NO ANIMATIONS
			print(c, ' can kill ', target, '. Attacking!')
			var success = resolveAttack(c, target)  #### HANDLES ANIMATION QUEUE AND CALLS NEXT ATTACKER
			return
			
		#### STEP 2 - ENEMY GROUP ATTACK TARGET CARD
		if not c.will_not_charge:
			handleDeclareCharge()
			
			#### CASE 2 - ATTACK AS PART OF CHARGE
			if enemyChargeTarget:
				var success = resolveAttack(c, enemyChargeTarget)  #### HANDLES ANIMATION QUEUE AND CALLS NEXT ATTACKER
				return
			
			#### CASE 3 - DON'T ATTACK
			else:
				handleEnemyCast(attackCard)   #### HANDLES ANIMATION QUEUE AND CALLS NEXT ATTACKER
				return
		
	#### CASE 3 - NO BLOCKERS, ATTACK PLAYER
	if blockers.is_empty():
		if not main.playerChampion():  #### CASE 3.1 - NO CHAMPION
			var damageToPlayer = c.getCombatDamageToTarget(null, true)
			main.changeHealth(-c.tempDamage, !c.isEnemyCard)
			main.updateResourceLabels()
			handlePortraitAttackPrintout(attackCard, damageToPlayer, false)

		else:  #### CASE 3.2 - CHAMPION ON BOARD
			var damageToChampion = c.getCombatDamageToTarget(main.playerChampion(), true)
			main.playerChampion().takeCombatDamage(c, true)
			handlePortraitAttackPrintout(attackCard, damageToChampion, false)
		
		c.handleAttackingPortrait()
		#### QUEUE THE ATTACK ANIMATIONS, THEN TELL RESPONSE QUEUE TO PLAY DEFENSE ANIMATIONS
		CardAnimationQueue.queueAnimation(c, c.animateAttackPortrait)
		CardAnimationQueue.queueFunction(CardAnimationQueue.startResponseQueue)
		CardAnimationQueue.queueAnimation(c, c.animateReturnToSlot)  
		#### HANDLES ANIMATION QUEUE AND CALLS NEXT ATTACKER
		CardAnimationQueue.queueAnimation(c, c.restAndAnimate, enemyAttackersWaiter)
		
		print("Attacked portrait: Calling Waiter")



#### Checks if attack card would die if it attacks defend card.
func check_if_survives(attackCard:Card, defendCard:Card) -> bool:
	var projected_damage = defendCard.getCombatDamageToTarget(attackCard, false)
	if projected_damage >= attackCard.tempHealth:
		return false
	else:
		return true

func check_if_kills(attackCard:Card, defendCard:Card) -> bool:
	var projected_damage = attackCard.getCombatDamageToTarget(defendCard, true)
	print(attackCard.cardName, ' will deal ', projected_damage, ' damage to ', defendCard)
	return projected_damage >= defendCard.tempHealth
		


func remove_dangerous(caller:Card, array:Array) -> Array:
	var arr:Array = array.duplicate()
	var dangerous = []
	for i:Card in arr:
		if not check_if_survives(caller, i):
			dangerous.append(i)
	for i:Card in dangerous:
		arr.erase(i)
	return arr


func remove_individually_unkillable(caller:Card, array:Array) -> Array:
	var killables = array.duplicate()
	var unkillable := []
	
	for c:Card in array:
		if not check_if_kills(caller, c):
			print(caller.cardName, ' cannot kill ', c.cardName)
			unkillable.append(c)
	for c in unkillable:		
		killables.erase(c)
	print(caller.cardName, ' can kill ', array)
	return killables

## CHARGE: If enemies decide they can kill a blocker by cooperating, they will
## prioritize it even if they can't beat it individually. This is called a charge.



func remove_unkillable_by_charge(array:Array) -> Array:
	print("Checking killable by charge: ",array)
	var killable = array.duplicate()
	var unkillable := []
	for c:Card in killable:
		if not check_if_kills_by_charge(c):
			print('The enemy team cannot kill ', c.cardName)
			unkillable.append(c)
	for c in unkillable:		
		killable.erase(c)
			
	print('The enemy team can kill ', killable)
	return killable


func check_if_kills_by_charge(card:Card):
	print('Against ', card.cardName, ', the enemy team has ', get_attacking_power(card), ' total power.')
	return card.tempHealth <= get_attacking_power(card)
	
	
func handleDeclareCharge():
	enemyChargeTarget = null
	var killable_by_charge: Array = getKillablePlayerBlockers()
	
	if not killable_by_charge.is_empty():
		enemyChargeTarget = killable_by_charge[0]
		print('Declaring charge! At ', enemyChargeTarget)
	print("Charge not initiated")



func get_attacking_power(defendCard:Card) -> int:
	var atk_power: int = 0
	for card:Card in CardChecks.getAttackersInList(enemyBoardCards):
		if card.checkCanAct() and not card.will_not_charge:
			atk_power += card.getCombatDamageToTarget(defendCard, true)
	return atk_power

func prioritize_charge_target(array:Array):
	if enemyChargeTarget in array:
		array.push_front(enemyChargeTarget)


	
#endregion

func playerAttackedSE():
	$SE/SE_Player_Damaged.pitch_scale = 1.0 + randf_range(0.2, -0.2)
	## The bell gets lower-pitched the lower the HP gets.
	if GameInfo.playerHealth < 20:
		$SE/SE_Player_Damaged.pitch_scale += 0.02 * (GameInfo.playerHealth - 10)
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
	


func _on_enemy_portrait_area_mouse_entered():
	damageCalculator.show()
	updateDamageCalculator(null)


func _on_enemy_portrait_area_mouse_exited():
	damageCalculator.hide()



func doNothing():
	pass
	
	
	
