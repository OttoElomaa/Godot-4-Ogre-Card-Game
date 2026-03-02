extends Node2D


var isPhased := false


var buffs:Array:
	get:
		return $Buff/Nodes.get_children()
var debuffs:Array:
	get:
		return $Debuff/Nodes.get_children()

@onready var myCard = get_parent()

@onready var buffSprites := $Buff/Sprites
@onready var debuffSprites := $Debuff/Sprites



func addEffect(appliedEffect: EffectCounter):
	var e = appliedEffect
	e.setup(myCard)
	
	match e.effectType:
		e.effectTypes.BUFF:
#			var foundEffect:CardEffect = 
			if has_similar(buffs, e):
				has_similar(buffs, e).increment()
				e.queue_free()
			else:
				e.reparent($Buff/Nodes)
				
		e.effectTypes.DEBUFF:
#			var foundEffect:CardEffect = has_similar(debuffs, e)
			if has_similar(debuffs, e):
				has_similar(debuffs, e).increment()
				e.queue_free()
			else:
				e.reparent($Debuff/Nodes)
				
	
	e.toggleIcon(false)
	
	updateEffectVisuals()
	
	var card:Card = get_parent()
#	var printout := "%s added on %s" % [appliedEffect.id, card.cardName]
#	MyTools.createCombatLogPrintout(printout, Color.WHITE)


func has_similar(array:Array, effect:EffectCounter) -> EffectCounter:
	for i:EffectCounter in array:
		if i.id == effect.id:
			return i
	return null


func updateEffectVisuals():
	var card:Card = get_parent()
	
	var effectName := ""
	var buffsCount = buffs.size()
	var debuffsCount = debuffs.size()
	
	for sprite in buffSprites.get_children():
		sprite.hide()
		
	for sprite in debuffSprites.get_children():
		sprite.hide()
	
	if buffsCount > 0:
		print("%d Buffs found on %s" % [buffs.size(), card.cardName])
	if debuffsCount > 0:
		print("%d Debuffs found on %s" % [debuffs.size(), card.cardName])	
	
	
	var sprite:Sprite2D = null
	
	for e:CardEffect in buffs:
		if MyTools.checkNodeValidity(e):
			sprite = buffSprites.get_children()[buffs.find(e)]
			
			sprite.show()
			sprite.texture = e.icon
			if e is EffectCounter:
				sprite.get_node("Amount").text = str(e.counter)
				if e.counter < 1 and !e.isPermanent:
					sprite.hide()
		
	for e:CardEffect in debuffs:
		if MyTools.checkNodeValidity(e):
			sprite = debuffSprites.get_children()[debuffs.find(e)]
			
			sprite.show()
			sprite.texture = e.icon
			if e is EffectCounter:
				sprite.get_node("Amount").text = str(e.counter)
				if e.counter < 1 and !e.isPermanent:
					sprite.hide()
	
		
	updatePhasedVisuals()
	
			
	
func togglePhased(isPhased:bool):
	self.isPhased = isPhased
	updatePhasedVisuals()



func updatePhasedVisuals():
	if isPhased:
		$PhasedTexture.show()
	else:
		$PhasedTexture.hide()
