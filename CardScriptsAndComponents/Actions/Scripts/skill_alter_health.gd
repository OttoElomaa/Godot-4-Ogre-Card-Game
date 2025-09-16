extends Skill



@export var bolsterDamage := 0
@export var bolsterHealth := 0

@export var inflictPlayer := 0
@export var inflictCreature := 0
@export var corrode := 0



func activate(targets:Array) -> bool:
	var success := false
	
	for target:Card in targets:
		#### INFLICT
		if inflictCreature > 0:
			handleInflict(target, inflictCreature)
			success = true

		#### CORRODE
		elif corrode > 0:
			handleCorrode(target, corrode)
			success = true
		
		#### BOLSTER
		elif bolsterDamage > 0 or bolsterHealth > 0:
			target.tempDamage += bolsterDamage
			target.tempHealth += bolsterHealth
			success = true
		
	return success
	


func createText() -> String:
	if bolsterDamage > 0 or bolsterHealth > 0:
		var text = "Bolster %d/%d" % [bolsterDamage, bolsterHealth]
		return text
	
		#### ADD INFLICT
	elif inflictCreature > 0:
		return "Inflict %d" % inflictCreature
	elif inflictPlayer > 0:
		return "Inflict Player %d" % inflictPlayer
	
	
	if corrode > 0:
		return "Corrode %d" % corrode
		
		
	return ""
	
	
	
	
	

#### DEAL TEMPORARY DAMAGE TO A CARD
func handleInflict(target:Card, amount:int):
	target.tempHealth -= amount
	
	if target.tempHealth <= 0:
		target.destroyAndAnimate(true)
		


#### DEAL TEMPORARY AND PERMANENT DAMAGE TO A CARD
func handleCorrode(target:Card, amount:int):
	#target.tempHealth -= amount
	target.health -= amount
	
	if target.tempHealth <= 0:
		target.destroyAndAnimate(true)
		
		
	
	
	
	
	
