extends Node2D



var isPhased := false


var buffs:
	get:
		return $Buff/Nodes.get_children()
var debuffs:
	get:
		return $Debuff/Nodes.get_children()



func addEffect(appliedEffect: EffectCounter):
	var e = appliedEffect
	
	match e.effectType:
		e.effectTypes.BUFF:
			e.reparent($Buff/Nodes)
		e.effectTypes.DEBUFF:
			e.reparent($Debuff/Nodes)
	
	e.toggleIcon(false)
	
	updateEffectInfo()		
	updateEffectVisuals()


func updateEffectInfo():
	pass


func updateEffectVisuals():
	
	var effectName := ""
	var buffIcon:Texture = null
	var debuffIcon:Texture = null
	
	for e:CardEffect in buffs:
		buffIcon = e.icon
	for e:CardEffect in debuffs:
		debuffIcon = e.icon
	
	for icon in $Buff/Sprites.get_children():
		icon.hide()
	for icon in $Debuff/Sprites.get_children():
		icon.hide()
	
	if debuffIcon != null:
		$Debuff/Sprites/DebuffSprite1.show()
	if buffIcon != null:
		$Buff/Sprites/BuffSprite1.show()
			
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
	
