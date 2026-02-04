extends MarginContainer
class_name CardContainer

@onready var art = $Frontside/Art
var card: Card = null


func _ready():
	pass

func insert_card(new_card:Card):
	
	card = new_card
	#### NEED TO INSTANTIATE THE CREATED CARD, SO IT CAN HAVE ITS OWN get_children() CALLS
	#### SO IT CAN BE SETUP PROPERLY, TO GET THE EFFECT TEXT ETC
	add_child(card)
	
	art.texture = card.cardArt
	
	$Frontside/ManaCost/ManaCostLabel.text = str(card.manaCost)
	$Frontside/Resources/Panel/HBox/PowerLabel.text = str(card.startingDamage)
	$Frontside/Resources/Panel/HBox/HealthLabel.text = str(card.startingHealth)
	$Frontside/EffectsLabel.text = card.createEffectText()
	
	if card.isRitual:
		$Frontside/Background/Creature.hide()
		$Frontside/Background/Spell.show()
		$Frontside/Resources/Panel/HBox/PowerLabel.hide()
		$Frontside/Resources/Panel/HBox/HealthLabel.hide()
		
	remove_child(card)

func display_card(new_card:PackedScene):
	
	var card = new_card.instantiate()
	await MyTools.createTempCard(card)
	insert_card(card.duplicate())
	MyTools.removeTempCard(card)
