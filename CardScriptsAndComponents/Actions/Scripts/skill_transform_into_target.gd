extends Skill

### Transforms user into the targeted card.
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
	var target:Card = targets[0]
	
	#### KEEP OR REPLACE NAME, FLAVOR TEXT AND ART
	if !card_name:
		myCard.cardName = target.cardName
	if !subtype:
		myCard.subTypeStr = target.subTypeStr
	if !flavor_text:
		myCard.flavorText = target.flavorText
	if !art:
		myCard.tempSetCardArt(target.cardArt)
		
	#### KEEP OR REPLACE STATS
	if !health:
		myCard.health = target.health
		myCard.tempHealth = myCard.health
	if !damage:
		myCard.damage = target.damage
		myCard.tempDamage = myCard.damage
	
	#### KEEP OR REPLACE ACTIONS	
	if !actions:
		for child in myCard.actions.get_children():
			myCard.actions.remove_child(child)
			
		## Duplicates the target's actions and gives them to the transformed card.
		for child in target.actions.get_children():
			myCard.actions.add_child(child.duplicate())
			myCard.actions.setup(myCard)
	
	if !effect_counters and !target.getEffects().is_empty():
		for counter:EffectCounter in target.getEffects():
			myCard.addEffect(counter)
	if !keywords and !target.getKeywords().is_empty():
		for kw:Keyword in target.getKeywords():
			myCard.addKeyword(kw.id)
	
	#### TRANSFORMATION COUNTS AS ARRIVAL (i think)
	myCard.handleArrival()  
	myCard.updateCardVisuals()
	myCard.updateCardNameAndBasicInfo(true)
	myCard.createEffectText()
	return true
