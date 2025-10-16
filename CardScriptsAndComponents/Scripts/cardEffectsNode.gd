extends Node2D



var isPhased := false


var buffs:Array:
	get:
		return $Buff/Nodes.get_children()
var debuffs:Array:
	get:
		return $Debuff/Nodes.get_children()

@onready var buffSprites := $Buff/Sprites
@onready var debuffSprites := $Debuff/Sprites



func addEffect(appliedEffect: EffectCounter):
	var e = appliedEffect
	
	match e.effectType:
		e.effectTypes.BUFF:
			var foundEffect:CardEffect = has_similar(buffs, e)
			if foundEffect:
				foundEffect.increment()
			else:
				e.reparent($Buff/Nodes)
				
		e.effectTypes.DEBUFF:
			var foundEffect:CardEffect = has_similar(debuffs, e)
			if foundEffect:
				foundEffect.increment()
			else:
				e.reparent($Buff/Nodes)
	
	e.toggleIcon(false)
	
	updateEffectInfo()		
	updateEffectVisuals()
	
	var card:Card = get_parent()
	var printout := "%s added on %s" % ["EffectName", card.cardName]
	MyTools.createCombatLogPrintout(printout, Color.WHITE)
	


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
		sprite.texture = null
		sprite.get_child(0).hide() ##Hides the label w/ amount
	for sprite in debuffSprites.get_children():
		sprite.texture = null	
		sprite.get_child(0).hide()
	
	if buffsCount > 0:
		print("%d Buffs found on %s" % [buffs.size(), card.cardName])
	if debuffsCount > 0:
		print("%d Debuffs found on %s" % [debuffs.size(), card.cardName])
		#assert(1==2,"Is this working?")	
	
	
	var sprite:Sprite2D = null
	var counter := 0
	
	for e:CardEffect in buffs:
		sprite = buffSprites.get_children()[counter]
		sprite.texture = e.icon
		if e is EffectCounter:
			sprite.get_child(0).show()
			sprite.get_child(0).text = str(e.counter)
		counter += 1
		
	counter = 0
	for e:CardEffect in debuffs:
		sprite = debuffSprites.get_children()[counter]
		sprite.texture = e.icon
		counter += 1
	
		
	updatePhasedVisuals()
	
			
		#### ONLY ONE EFFECT TYPE ALLOWED
		#if e.getEffectName() != effectName:
			#if effectName != "":
				#e.queue_free()
		#effectName = e.getEffectName()
		
	
func togglePhased(isPhased:bool):
	self.isPhased = isPhased
	updatePhasedVisuals()



func updatePhasedVisuals():
	if isPhased:
		$PhasedTexture.show()
	else:
		$PhasedTexture.hide()



func hasDoom() -> bool:
	
	for effect:CardEffect in debuffs:
		if effect.isDoom:
			return true
	return false
	
