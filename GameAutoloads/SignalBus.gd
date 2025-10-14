extends Node

signal turnStarted

##	One argument: the card that arrived
signal arrival(args:Array)
##	One argument: the champion that was placed
signal champion_placed(args:Array)

signal cast_pressed(args:Array)
signal cast(args:Array)
signal ritual

##	Two arguments. 0: the attacking card, 1: the defending card
signal attacked(args:Array)
signal defended(args:Array)

##	One argument: the card that died
signal death(args:Array)



#enum LocalSituations {
#	NONE, ARRIVAL, CAST, BATTLE_ART, ON_TURN, RITUAL
#}
#enum GlobalSituations {
#	NONE, ON_RITUAL, ON_CREATURE_ARRIVAL, ON_CREATURE_DEATH, ON_ALLY_DEATH, ON_ENEMY_DEATH
#	}
