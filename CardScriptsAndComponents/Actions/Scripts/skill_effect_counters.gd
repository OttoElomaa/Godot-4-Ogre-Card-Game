extends Skill


@export var grantEffect: PackedScene
@export var grantAmount := 0

@export var phaseOut := false


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
			success = handleGrantEffect(target)
			
		#### PHASE OUT
		if phaseOut:
			success = handlePhaseOut(target)
	
		
	return success
	
	

func handleGrantEffect(target:Card) -> bool:
	var success := false
	for i in range(grantAmount):
				
		var effect:CardEffect = grantEffect.instantiate() #### INSTANTIATE
		add_child(effect) #### TEMPORARY BEFORE REPARENTING
		
		target.addEffect(effect)
		target.updateCardVisuals()
		success = true
	
	return success



func handlePhaseOut(target:Card) -> bool:
	target.effects.togglePhased(true)
	target.statesPassive()
	var success = true
	return success
