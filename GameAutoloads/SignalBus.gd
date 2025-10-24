extends Node

signal turnStarted(params:SignalParams)

##	One argument: the card that arrived
signal arrival(params:SignalParams)
##	One argument: the champion that was placed
signal champion_placed(params:SignalParams)

signal cast_pressed(params:SignalParams)
signal cast(params:SignalParams)
signal ritual(params:SignalParams)

##	Two arguments. 0: the attacking card, 1: the defending card
signal attacked(params:SignalParams)
signal defended(params:SignalParams)

##	One argument: the card that died
signal death(params:SignalParams)
