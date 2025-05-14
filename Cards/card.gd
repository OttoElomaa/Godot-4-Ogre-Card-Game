extends Node2D
class_name Card


signal hoverOn
signal hoverOff


@export var startingDamage := 0
@export var startingHealth := 0

var mySlot: CardSlot = null
var myOffset := Vector2.ZERO
var allowInteract := true


func _ready() -> void:
	var cardManager = get_parent().get_parent()
	cardManager.connectCardSignal(self)
	
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


func checkInteractAllowed():
	return allowInteract


func toggleFrontSide(toShow:bool):
	if toShow:
		$Frontside.show()
	else:
		$Frontside.hide()
