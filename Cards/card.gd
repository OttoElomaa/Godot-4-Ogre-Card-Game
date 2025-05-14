extends Node2D
class_name Card


signal hoverOn
signal hoverOff


@export var startingDamage := 0
@export var startingHealth := 0

var mySlot: CardSlot = null
var myOffset := Vector2.ZERO


func _ready() -> void:
	var cardManager = get_parent().get_parent()
	cardManager.connectCardSignal(self)
	
	myOffset = get_parent().position
	
	$StatsPanel/HBox/PowerLabel.text = "%d" % startingDamage
	$StatsPanel/HBox/HealthLabel.text = "%d" % startingHealth
	


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hoverOn", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hoverOff", self)
