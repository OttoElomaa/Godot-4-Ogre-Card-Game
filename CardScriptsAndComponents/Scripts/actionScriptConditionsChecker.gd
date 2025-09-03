extends Node


enum SpecialConditions {NONE, ON_RITUAL, ON_CREATURE_ARRIVAL, ON_CREATURE_DEATH, ON_ALLY_DEATH, ON_ENEMY_DEATH}



@export var specialCondition := SpecialConditions.NONE






func triggerConditionRitual():
	pass


func triggerConditionCreatureDeath():
	pass


func triggerConditionAllyDeath():
	pass	
