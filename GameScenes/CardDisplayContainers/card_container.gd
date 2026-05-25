extends MarginContainer
class_name CardContainer

@onready var art = $Frontside/Art
var card: Card = null


func _ready():
	pass


## Puts a Card-class object into the container.
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

## Puts a PackedScene-type object into the container.
func display_card_packed(new_card:PackedScene):
	var card:Card = new_card.instantiate()
	display_card(card)
	

func display_card(new_card:Card):	
	#await MyTools.createTempCard(card)
	insert_card(new_card.duplicate())
	#MyTools.removeTempCard(card)
