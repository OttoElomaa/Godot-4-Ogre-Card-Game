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
	updateResourceLabels()
	
	
	
func updateResourceLabels():
	$Scenery/PlayerHealthLabel.text = "%d" % playerHealth
	$Scenery/PlayerManaLabel.text = "%d" % playerMana
	$Scenery/EnemyHealthLabel.text = "%d" % enemyHealth
	$Scenery/EnemyManaLabel.text = "%d" % enemyMana



func _input(e: InputEvent) -> void:
	
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
	

func passTurn():
	cardsManager.wakeEnemyCards()
	enemyPlayTurn()
	
	turnCount += 1
	playerMana = turnCount
	enemyMana = turnCount
	updateResourceLabels()
	
	cardsManager.wakePlayerCards()
	main.updateUi(turnCount)
	cardsManager.startPlayerTurn()



func enemyPlayTurn():
	var enemyHandCards = cardsManager.getEnemyHandCards()
	for card:Card in enemyHandCards:
		if card.manaCost <= enemyMana:
			var success = playEnemyCard(card)
			if success:
				enemyMana -= card.manaCost
		
				

func playEnemyCard(card:Card):
	for slot:CardSlot in main.getEnemySlots():
		if slot.isAvailable:
			cardsManager.placeCardInSlot(card, slot)
			card.reparent(cardsManager.get_node("EnemyBoard"))
			return true
	return false


#############################################################################

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
	enemyHealth -= currentAttackingCard.damage
	currentAttackingCard.rest()


func handlePlayerAttackCreature(results:Array):
	
	var target:Card = getCollidedObject(results[0])
	#### INVALID TARGET - END TARGETING ANYWAY
	if not target.mySlot:
		if target != currentAttackingCard:
			endAttackState()
		return
	if main.checkSlotPlayer(target.mySlot):
		if target != currentAttackingCard:
			endAttackState()
		return
	
	#### VALID TARGET - RESOLVE ATTACK
	if main.checkSlotEnemy(target.mySlot):
		prints("Player card targets enemy card: ", currentAttackingCard, target)
		endAttackState()
		resolveAttack(currentAttackingCard, target)
		

	#attackLineShown = false

	


func resolveAttack(attackCard:Card, targetCard:Card):
	var cardsToDestroy := []
	if attackCard.checkHasLethalOn(targetCard):
		cardsToDestroy.append(targetCard)
	if targetCard.checkHasLethalOn(attackCard):
		cardsToDestroy.append(attackCard)
		
	#### HANDLE DESTROYING THE CARDS THAT TOOK LETHAL DAMAGE
	currentAttackingCard.rest()
	for c:Card in cardsToDestroy:
		c.mySlot.isAvailable = true
		c.queue_free()


func endAttackState():
	attackLineShown = false
	$AttackLine.hide()
	States.gameState = States.GameStates.PLAY
	
	

func togglePlayerAttackMode(enable:bool, card:Card):
	
	if card.checkNotResting():
		currentAttackingCard = card
		States.gameState = States.GameStates.ATTACK
		
		attackLineShown = enable
		$AttackLine.show()
		attackLine.points[0] = card.position


############################################################################

func getCollidedObject(result):
	return result.collider.get_parent()
	
	
	
	
