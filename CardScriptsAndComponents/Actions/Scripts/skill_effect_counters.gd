extends Skill


@export var grantEffect: PackedScene
@export var grantAmount := 0


func activate(targets:Array) -> bool:
	var success := false
	
	#### TARGETED ACTIONS
	for target:Card in targets:

		#### ADD AN AMOUNT OF EFFECT COUNTERS
		if grantEffect:
			success = handleGrantEffect(target)
			
		
	
		
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
