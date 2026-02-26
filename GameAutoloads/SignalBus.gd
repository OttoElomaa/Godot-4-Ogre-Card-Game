extends Node

signal turnStarted(params:SignalParams)
signal turnEnded(params:SignalParams)

signal arrival(params:SignalParams)
signal champion_placed(params:SignalParams)

signal cast(params:SignalParams)
signal ritual(params:SignalParams)

signal attacked(params:SignalParams)
signal defended(params:SignalParams)
signal damage_taken(params:SignalParams)

signal death(params:SignalParams)
signal death_defied(params:SignalParams)
signal survived(params:SignalParams)
signal killed_enemy(params:SignalParams)

####
signal disp_card(cardName:String)
signal hide_card(cardName:String)
signal hide_all()

signal unlock_node(id:String)
signal resolve_node(id:String)
