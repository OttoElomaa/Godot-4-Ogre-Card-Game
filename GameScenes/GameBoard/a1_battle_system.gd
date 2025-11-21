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
@export var enemyHealth := 20

var playerAttackOngoing: bool = false
var currentAttackingCard: Card = null

var castLineShown: bool = false
var currentCastingCard: Card = null

var enemyChargeTarget: Card = null
var enemyBoardCards:Array:
	get:
		return cardsManager.getEnemyBoardCards()


func _ready() -> void:
	
	turnCount += 1
	playerMana = turnCount
	enemyMana = turnCount
	GameInfo.enemy_turn = false
#	updateResourceLabels()
	
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
		await timeoutEnemyStartCombat()
		
	
	
func switchBetweenPlayerEnemyTurns():
	#### SWITCH TURN TYPE BETWEEN PLAYER <--> ENEMY
	GameInfo.enemy_turn = !GameInfo.enemy_turn
	
	if GameInfo.enemy_turn:
		print("Enemy turn start")
	else:
		print("Player turn start")
	
	var signalparams = SignalParams.new()
	SignalBus.turnStarted.emit(null)
	
	

## Enemy summons creatures.
func enemySummonCreatures() -> void:
	main.addLogMessage("Opponent turn!", Color.html("524634"))
	
	#### PLAY CARDS FROM HAND
	var enemyHandCards := cardsManager.getEnemyHandCards()
	
	for card:Card in enemyHandCards:
		if MyTools.checkNodeValidity(card):
			if card.manaCost <= enemyMana:
				if not card.isRitual:
					var success = playEnemyCard(card)
					if success:
						enemyMana -= card.manaCost

func enemyPlayRituals() -> void:
	var enemyHandCards := cardsManager.getEnemyHandCards()
	
	for card:Card in enemyHandCards:
		if MyTools.checkNodeValidity(card):
			if card.manaCost <= enemyMana:
				if card.isRitual:
					handlePlayerRitual(card)


func timeoutEnemyStartCombat() -> void:
	#### ATTACK WITH CARDS ON BOARD
	var AI_Personality = main.AI_personality
	enemyChargeTarget = null
	
	#### TANK CARDS DO NOT ACT ON THEIR TURN.
	for card:Card in enemyBoardCards:
		card.statesPassive()
		if card.action_mode == card.actionMode.TANK:
			card.statesActive()
			
	### IF THERE ARE NO BLOCKING CARDS, THE STRONGEST ENEMY CARDS ARE SET TO BLOCK.

		
	#### Perform actions in an order based on AI Personality.
	match AI_Personality:
		main.AI_personalities.COMMANDER:
			await enemySummonCreatures()
			await enemyPlayRituals()
			await decide_blockers()
			await playCasters()
			await playAttackers()
		main.AI_personalities.WIZARD:
			if cardsManager.getEnemyBlockers().is_empty():
				await enemySummonCreatures()
				await decide_blockers()
			await enemyPlayRituals()
			await playCasters()
			await playAttackers()
			await enemySummonCreatures()
			await decide_blockers()
		main.AI_personalities.SPECIALIST:
			await playCasters()
			await enemySummonCreatures()
			await enemyPlayRituals()
			await decide_blockers()
			await playAttackers()


	timeoutEndEnemyTurn()

func get_casters():
	var casters = []
	for i:Card in enemyBoardCards:
		if i.action_mode == i.actionMode.CASTER:
			casters.append(i)
	sort_by_priority(casters)
	return casters

func get_attackers():
	var attackers = []
	for i:Card in enemyBoardCards:
		if i.action_mode == i.actionMode.ATTACKER:
			attackers.append(i)
	sort_by_strongest(attackers)
	sort_by_priority(attackers)
	print(attackers)
	return attackers

func get_non_blockers() -> Array:
	var non_blockers = []
	for i:Card in enemyBoardCards:
		if not i.checkCanBlock():
			non_blockers.append(i)
	sort_by_strongest(non_blockers)
	return non_blockers

func decide_blockers():
	if enemyBoardCards.is_empty():
		return
		
	sort_by_strongest(enemyBoardCards)
	var projected_number_of_blockers = roundi(cardsManager.getPlayerBoardCards().size() / 2) - cardsManager.getEnemyBlockers().size()
	
	for i in range(projected_number_of_blockers):
		var blocker:Card = get_non_blockers().front()
		blocker.statesActive()

func playCasters():
	var enemyCasters = get_casters()
	for card:Card in enemyCasters:
		await handleEnemyCast(card)
		
### ATTACKERS ATTACK OR CAST STARTING FROM THE PRIORITIZED/STRONGEST ONES.
func playAttackers():
	var enemyAttackers = get_attackers()
	for card:Card in enemyAttackers:
		if card.checkCanAct():
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
#region### PLAYER ATTACK FUNCTIONS

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
	if not targetC:
		damageToDealLabel.text = "%d" % (attacker.getCombatDamageToTarget(attacker, true) + extraDamage2Defender) 
		damageToTakeLabel.text = "0"
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
		return


#### FOR PLAYING 'RITUAL' CARDS
func handlePlayerRitual(c:Card) -> bool:
	var success := false
	if !c.isEnemyCard:
		if playerMana < c.manaCost: #### CAN'T AFFORD, RETURN
			return success
	
	#### RESOLVE RITUAL IN CARD'S ACTION NODE (Could be TARGETED or TARGETLESS)
	success = await c.actions.handleRitual()
	
	if success:
		cardsManager.discardCard(c)
		if !c.isEnemyCard:
			playerMana -= c.manaCost
		else:
			enemyMana -= c.manaCost
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
	endAttackState()
	await main.playAttackPortraitAnimation(c)
	main.changeHealth(-combatDamage, !c.isEnemyCard)
	updateResourceLabels()
	handlePortraitAttackPrintout(c, combatDamage, true)
	main.shake_screen(10, 0.5)
	await c.returnToSlot()
	
	
#endregion

#region### ENEMY ATTACKER AI
#### BTW, PlayAttackAnimation CALLS THE CARD DESTROY COMMAND
func handleEnemyAttackPlayer(attackCard: Card) -> void:
	
	var c = attackCard
	var blockers:Array = cardsManager.getPlayerBlockers()
	var target:Card = null
	var action_modes = attackCard.actionMode

	
	#### PLAYER HAS BLOCKERS, FIND KILLABLE BLOCKER
	if not blockers.is_empty():
		sort_by_weakest(blockers)
		### CHECK IF THIS CARD CAN KILL AN ENEMY BY ITSELF.
		if not c.fearless:
			var individually_killable: Array = blockers
			remove_individually_unkillable(attackCard, individually_killable)
			if individually_killable.size() > 0:
				target = individually_killable[0]
		else:
			target = blockers.front()
		#### TARGET FOUND, ATTACK TARGET CARD
		if target:
		#### IF ATTACKER DESTROYED, NO ANIMATIONS
			print(c, ' can kill ', target, '. Attacking!')
			var success = await resolveAttack(c, target)
			return
		elif not c.will_not_charge:
			
			var killable_by_charge: Array = cardsManager.getPlayerBlockers()
			enemyChargeTarget = null
			remove_unkillable_by_charge(killable_by_charge)
			if killable_by_charge.size() > 0:
				declare_charge(killable_by_charge[0])
			
			if enemyChargeTarget:
				var success = await resolveAttack(c, enemyChargeTarget)
				return
			
			else:
				await handleEnemyCast(attackCard)
		
		return
		
	#### NO BLOCKERS, ATTACK PLAYER
	if blockers.is_empty():
		if not main.playerChampion():
			var damageToPlayer = c.getCombatDamageToTarget(null, true)
			await main.playAttackPortraitAnimation(c)
			main.changeHealth(-c.tempDamage, !c.isEnemyCard)
			updateResourceLabels()
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

func handleEnemyCast(castingCard:Card):
	if castingCard.actions.getCastAction():
		await castingCard.actions.handleCast()


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
		
#### Calculates a card's relative power to the caller. Most enemies are less
#### eager to attack cards with higher power.
func get_card_power(card:Card) -> int:
	var power: int = 0
	power = card.tempDamage + card.tempHealth
	return power

func get_weaker(card_1:Card, card_2:Card) -> bool:
	return get_card_power(card_1) < get_card_power(card_2)

func get_stronger(card_1:Card, card_2:Card) -> bool:
	return get_card_power(card_1) > get_card_power(card_2)

#### Sorts an array of Cards with weakest ones going to the front.
func sort_by_weakest(array:Array) -> Array:
	array.sort_custom(get_weaker)
	return array

func sort_by_strongest(array:Array) -> Array:
	array.sort_custom(get_stronger)
	return array

func remove_dangerous(caller:Card, array:Array) -> Array:
	var dangerous = []
	for i:Card in array:
		if not check_if_survives(caller, i):
			dangerous.append(i)
	for i:Card in dangerous:
		array.erase(i)
	return array

func remove_individually_unkillable(caller:Card, array:Array) -> Array:
	var unkillables = []
	for i:Card in array:
		if not check_if_kills(caller, i):
			print(caller.cardName, ' cannot kill ', i.cardName)
			unkillables.append(i)
	for i in unkillables:
		array.erase(i)
	print(caller.cardName, ' can kill ', array)
	return array

## CHARGE: If enemies decide they can kill a blocker by cooperating, they will
## prioritize it even if they can't beat it individually. This is called a charge.

func check_if_kills_by_charge(card:Card):
	print('Against ', card.cardName, ', the enemy team has ', get_attacking_power(card), ' total power.')
	return card.tempHealth <= get_attacking_power(card)

func remove_unkillable_by_charge(array:Array) -> Array:
	print(array)
	var unkillable = []
	for i:Card in array:
		if not check_if_kills_by_charge(i):
			print('The enemy team cannot kill ', i.cardName)
			unkillable.append(i)
	for i:Card in unkillable:
		array.erase(i)
	print('The enemy team can kill ', array)
	return array

func declare_charge(target: Card):
	enemyChargeTarget = target
	print('Declaring charge! At ', enemyChargeTarget)

func get_attacking_power(defendCard:Card) -> int:
	var atk_power: int = 0
	for card:Card in get_attackers():
		if card.checkCanAct() and not card.will_not_charge:
			atk_power += card.getCombatDamageToTarget(defendCard, true)
	return atk_power

func prioritize_charge_target(array:Array):
	if enemyChargeTarget in array:
		array.push_front(enemyChargeTarget)

##Sorts cards in an Array based on their priotity.
func get_higher_priority(a:Card, b:Card):
	return a.priority > b.priority

func sort_by_priority(array:Array):
	array.sort_custom(get_higher_priority)
	return array
	
#endregion

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
#### DUMMIED CODE: ALLOWS TARGETING PASSIVES IS THERE ARE NO BLOCKERS.
#	elif not cardsManager.getEnemyBlockers().is_empty() and not target.checkCanBlock():
#		end = true
#### CANNOT TARGET PASSIVES AT ALL.
	elif not target.checkCanBlock():
		end = true
	elif not target.allowInteract:
		print('Already fighting!')
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
	var attackerDestroyed = await attackCard.checkAndHandleCombatDeath(true)
	var targetDestroyed = await targetCard.checkAndHandleCombatDeath(false)
	
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
	

func _on_enemy_portrait_area_mouse_entered():
	damageCalculator.show()
	updateDamageCalculator(null)


func _on_enemy_portrait_area_mouse_exited():
	damageCalculator.hide()
