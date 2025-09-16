extends Skill



@export var rest := false
@export var travel := false

@export var wake := false
@export var arrive := false




func activate(targets:Array) -> bool:
	var success := false
	
	
	#### TARGETED ACTIONS
	for target:Card in targets:
		
		#### CARD DRAW
		if rest:
			target.restAndAnimate(true)
			success = true

		
	return success
	


func createText() -> String:
	var text := ""
	

	if rest:
		text = "Rest"
	elif travel:
		text = "Travel"
	elif wake:
		text = "Wake"
	elif arrive:
		text = "Arrive"
	
	
	return text
