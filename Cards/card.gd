extends Node2D
class_name Card


signal hoverOn
signal hoverOff

#### ACTIVE = Combatant, can be targeted, protects player from being targeted
#### PASSIVE = Can't be targeted, doesn't protect
#### RESTING = Can't take card actions this turn, such as attack or cast.
#### RESTING IS TRIGGERED by entering the field, attacking, or casting
#### --> Unless "Haste/Vigilant" kind of effects
#### ACTIVE / PASSIVE IS TRIGGERED in a right click menu on top of card
enum CardActionStates {
	ACTIVE, PASSIVE, RESTING, TRAVELING
}

@export var manaCost := 0
@export var startingDamage := 0
@export var startingHealth := 0
var damage := 0
var health := 0

@onready var stateHandler := $Frontside/ActionState

var isEnemyCard := false
var mySlot: CardSlot = null
var myOffset := Vector2.ZERO

var allowInteract := true
var actionState: CardActionStates = CardActionStates.ACTIVE

var isTraveling := false
var resting := false


@export var hasSunder := false
@export var hasDuelist := false



func _ready() -> void:
	var cardManager = get_parent().get_parent()
	cardManager.connectCardSignal(self)
	
	damage = startingDamage
	health = startingHealth
	myOffset = get_parent().position
	
	$Frontside/StatsPanel/HBox/PowerLabel.text = "%d" % startingDamage
	$Frontside/StatsPanel/HBox/HealthLabel.text = "%d" % startingHealth
	
	var l = $Frontside/EffectsLabel
	var text = ""
	if hasSunder:
		text += "Sunder"
	if hasDuelist:
		text += "Duelist"
	l.text = text
	


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hoverOn", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hoverOff", self)



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


#############################################################

func rest():
	resting = true

func restAndAnimate():
	resting = true
	rotateRestingCard(true)


func wake():
	resting = false
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
	stateHandler.get_node("PassiveIcon").hide()
	
	
func statesPassive():
	actionState = CardActionStates.PASSIVE
	stateHandler.get_node("ActiveIcon").hide()
	stateHandler.get_node("PassiveIcon").show()
	


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

func checkActive() -> bool:
	if actionState == CardActionStates.ACTIVE:
		if checkNotResting():
			return true
	return false


func checkNotResting() -> bool:
	return !resting

func checkNotTraveling() -> bool:
	if isTraveling:
		return false
	return true

#func checkValidTarget() -> bool:
	#return checkActive()


########################################################


#### DEAL DAMAGE IF NECESSARY, AND RETURN ANSWER: DID THIS CARD DIE
func takeDamageAndCheckLethal(card:Card) -> bool:
	
	#### HANDLE DESTROYED STATUS	
	var selfDestroyed := false
	if card.damage >= health:
		selfDestroyed = true
	
	#### HANDLE DAMAGE -> SUNDER Keyword
	if card.hasSunder:
		health -= card.damage
	
	#### UPDATE VISUALS AND RETURN DESTROYED STATUS
	updateCardLabels()
	return selfDestroyed



func toggleEnemyStatus(enabled:bool):
	isEnemyCard = enabled
	

###########################################################################

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


func playAttackAnimation():
	if isEnemyCard:
		$BodyAnimations.play("EnemyAttack")
	else:
		$BodyAnimations.play("PlayerAttack")
	$BodyAnimations/AnimationsTimer.start()


#### FOR RESTING
func _on_animations_timer_timeout() -> void:
	rotateRestingCard(true)
	

#######################################################################

func rotateRestingCard(willRest:bool):
	var degreesGoal = 0
	if willRest:
		degreesGoal = 25
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation_degrees", degreesGoal, 0.2)


func updateCardLabels():
	$Frontside/StatsPanel/HBox/HealthLabel.text = "%d" % health
	$Frontside/StatsPanel/HBox/PowerLabel.text = "%d" % damage
