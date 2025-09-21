extends Node

signal turnStarted
signal arrival(card:Card)
signal cast
signal ritual
signal attacked(card:Card)
signal defended(card:Card)
signal death(card:Card)

#enum LocalSituations {
#	NONE, ARRIVAL, CAST, BATTLE_ART, ON_TURN, RITUAL
#}
#enum GlobalSituations {
#	NONE, ON_RITUAL, ON_CREATURE_ARRIVAL, ON_CREATURE_DEATH, ON_ALLY_DEATH, ON_ENEMY_DEATH
#	}
