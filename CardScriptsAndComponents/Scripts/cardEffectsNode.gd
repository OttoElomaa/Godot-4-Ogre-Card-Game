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
	
	updateEffectInfo()		
	updateEffectVisuals()
	
	var card:Card = get_parent()
#	var printout := "%s added on %s" % [appliedEffect.id, card.cardName]
#	MyTools.createCombatLogPrintout(printout, Color.WHITE)
	


func updateEffectInfo():
	pass


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
	var counter := 0
	
	for e:CardEffect in buffs:
		sprite = buffSprites.get_children()[counter]
		
		sprite.show()
		sprite.texture = e.icon
		if e is EffectCounter:
			sprite.get_node("Amount").text = str(e.counter)
			if e.counter < 1:
				sprite.hide()
		counter += 1
		
	counter = 0
	for e:CardEffect in debuffs:
		sprite = debuffSprites.get_children()[counter]
		
		sprite.show()
		sprite.texture = e.icon
		if e is EffectCounter:
			sprite.get_node("Amount").text = str(e.counter)
		counter += 1
	
		
	updatePhasedVisuals()
	
			
	
func togglePhased(isPhased:bool):
	self.isPhased = isPhased
	updatePhasedVisuals()



func updatePhasedVisuals():
	if isPhased:
		$PhasedTexture.show()
	else:
		$PhasedTexture.hide()
