extends Node2D

enum AutomaticTargetOptions {
	NONE, ALLIES, ENEMIES, ALL
	}
enum ManualTargetOptions {
	NONE, ALLY, ALLIES, ENEMY, ENEMIES, ALL
	}

@export var automaticTargetGroup := AutomaticTargetOptions.NONE

@export var manualTargetGroup := ManualTargetOptions.NONE

#enum DetailedTargetingOptions {NONE, STRONGEST, WEAKEST,}



func getTargets(isEnemy:bool) -> Array:
	var targets := []
	
	var aut := AutomaticTargetOptions
	var man := ManualTargetOptions
	
	
	match automaticTargetGroup:
		aut.ALLIES:
			return MyTools.getBoardCards(isEnemy)
		aut.ENEMIES:
			return MyTools.getBoardCards(!isEnemy)
		aut.ALL:
			var allCreatures:Array = MyTools.getBoardCards(isEnemy)
			allCreatures.append_array(MyTools.getBoardCards(!isEnemy))
			return allCreatures
	
	return targets
	
	
	
		
