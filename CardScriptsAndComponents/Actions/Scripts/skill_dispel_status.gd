extends Skill

@export_category('Type To Dispel')
@export var buffs = false
@export var debuffs = false

func activate(targets:Array):
	var success = false
	for target:Card in targets:
		for effect:EffectCounter in target.getEffects():
			if effect.isPermanent:
				continue

			if effect.effectType == effect.effectTypes.BUFF and buffs:
				target.removeEffect(effect)
			elif effect.effectType == effect.effectTypes.DEBUFF and debuffs:
				target.removeEffect(effect)
	
	success = true
	return success
