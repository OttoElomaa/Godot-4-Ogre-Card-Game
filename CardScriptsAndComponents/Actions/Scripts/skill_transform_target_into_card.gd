extends Skill

### Transforms new_card into an assigned card.
@export var transform_into: PackedScene = null


### Check any boxes that you wish the card would keep from its original form.

@export_category('Keep Stats')
@export var card_name = false
@export var subtype = false
@export var flavor_text = false
@export var art = false
@export var health = false
@export var damage = false
@export var actions = false
@export var effect_counters = false
@export var equipment = false
@export var keywords = false

func activate(targets):
	var new_card: Card = transform_into.instantiate()
	MyTools.createTempCard(new_card)
	
	for t:Card in targets:
		if !card_name:
			t.cardName = new_card.cardName
		if !subtype:
			t.subTypeStr = new_card.subTypeStr
		if !flavor_text:
			t.flavorText = new_card.flavorText
		if !art:
			t.tempSetCardArt(new_card.cardArt)
		if !health:
			t.health = new_card.health
			t.tempHealth = t.health
		if !damage:
			t.damage = new_card.damage
			t.tempDamage = t.damage
			
		if !actions:
			## Removes all actions from the original.
			for child in t.actions.get_children():
				t.actions.remove_child(child)
				
			## Duplicates the new_card's actions and gives them to the transformed card.
			for child in new_card.actions.get_children():
				t.actions.add_child(child.duplicate())
				t.actions.setup(t)
		
		if !effect_counters and !new_card.getEffects().is_empty():
			for counter:EffectCounter in new_card.getEffects():
				t.addEffect(counter)
		if !keywords and !new_card.getKeywords().is_empty():
			for kw:Keyword in new_card.getKeywords():
				t.addKeyword(kw.id)
		
		t.updateCardVisuals()
		t.updateCardNameAndBasicInfo(true)
		t.createEffectText()
		MyTools.removeTempCard(new_card)
		
	return true
