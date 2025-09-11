extends Skill



@export var drawCards := 0

@export var summonScene: PackedScene = null
@export_multiline var summonString := "Summon a thing"



func activate(targets:Array) -> bool:
	var success := false
	
	#### CARD DRAW
	if drawCards > 0:
		for i in range(drawCards):
			MyTools.handleDrawCard(action.isEnemy)
		success = true
	
	#### SUMMON
	elif summonScene:
		var creature:Card = summonScene.instantiate()
		add_child(creature)   #### TEMP PARENT TO TRIGGER _READY
		success = MyTools.summonCard(creature, action.isEnemy)
		
	#### TARGETED ACTIONS
	for target:Card in targets:
		pass

		
	return success
	


func createText() -> String:
	var text := ""
	
	#### CARD DRAW
	if drawCards > 0:
		text = "Draw %d" % drawCards
	
	#### ADD SUMMON
	elif summonScene:
		text = summonString
	
	return text
