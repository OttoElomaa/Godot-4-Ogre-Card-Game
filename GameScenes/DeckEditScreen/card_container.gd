extends MarginContainer

@export var card: Card = null
@onready var art = $Frontside/Art

func _ready():
	art.texture = card.cardArt
	
	#### NEED TO INSTANTIATE THE CREATED CARD, SO IT CAN HAVE ITS OWN get_children() CALLS
	#### SO IT CAN BE SETUP PROPERLY, TO GET THE EFFECT TEXT ETC
	add_child(card)
	card.hide()
	
	$Frontside/ManaCost/ManaCostLabel.text = str(card.manaCost)
	$Frontside/Resources/Panel/HBox/PowerLabel.text = str(card.startingDamage)
	$Frontside/Resources/Panel/HBox/HealthLabel.text = str(card.startingHealth)
	$Frontside/EffectsLabel.text = card.createEffectText()
	
	remove_child(card)
	
	
	
func _get_drag_data(at_position):
	var data = [card, false]
	set_drag_preview(self.duplicate())
	
	return data

func _on_mouse_entered():
	get_parent().card_mouse_entered.emit(card)


func _on_mouse_exited():
	get_parent().card_mouse_exited.emit()
