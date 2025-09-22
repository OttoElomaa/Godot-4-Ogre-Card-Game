extends Skill


@export var grantEffect:EffectCounter
@export var grantAmount := 0

@export var phaseOut := false

@export var alterOwnerHealth := 0
@export var alterOwnerMana := 0
@export var alterOpponentHealth := 0
@export var alterOpponentMana := 0




func activate(targets:Array) -> bool:
	var success := false
	
	#### PHASE OUT SELF
	if targets.is_empty():
		if phaseOut:
			myCard.effects.togglePhased(true)
			myCard.statesPassive()
			success = true

	#### TARGETED ACTIONS
	for target:Card in targets:

		#### ADD AN AMOUNT OF EFFECT COUNTERS
		if grantEffect:
			for i in range(grantAmount):
				
				var effect:CardEffect = grantEffect.instantiate() #### INSTANTIATE
				add_child(effect) #### TEMPORARY BEFORE REPARENTING
				
				target.addEffect(effect)
				target.updateCardVisuals()
				success = true


		#### PHASE OUT
		if phaseOut:
			target.effects.togglePhased(true)
			target.statesPassive()
			success = true
	
		
	return success
	


func createText() -> String:
	var text := ""
	
	#### TEXT: ADD AN EFFECT COUNTER
	if grantEffect:
		var effect:CardEffect = grantEffect.instantiate()
		var effectName:String = effect.getEffectName()
		text += "Add %d %s to target" % [grantAmount, effectName]
	
	
	
	return text
