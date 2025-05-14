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
	ACTIVE, PASSIVE, RESTING
}

@export var startingDamage := 0
@export var startingHealth := 0
var damage := 0
var health := 0

var mySlot: CardSlot = null
var myOffset := Vector2.ZERO

var allowInteract := true
var actionState: CardActionStates = CardActionStates.ACTIVE


func _ready() -> void:
	var cardManager = get_parent().get_parent()
	cardManager.connectCardSignal(self)
	
	damage = startingDamage
	health = startingHealth
	myOffset = get_parent().position
	
	$Frontside/StatsPanel/HBox/PowerLabel.text = "%d" % startingDamage
	$Frontside/StatsPanel/HBox/HealthLabel.text = "%d" % startingHealth
	


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


func checkActive() -> bool:
	if actionState == CardActionStates.ACTIVE:
		return true
	return false


func checkHasLethalOn(card:Card):
	return (damage > card.health)
