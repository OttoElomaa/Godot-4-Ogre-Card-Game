@icon("res://Art/icons/16x16/heart.png")
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
			var damage = inflictCreature
			if isScaled():
				damage = get_scaling({'target': target})
			handleInflict(target, damage)
			success = true

		#### CORRODE
		elif corrode > 0:
			var damage = corrode
			if isScaled():
				damage = get_scaling({'target': target})
			handleCorrode(target, damage)
			success = true
		
		#### BOLSTER
		elif bolsterDamage > 0 or bolsterHealth > 0:
			target.tempDamage += bolsterDamage
			target.tempHealth += bolsterHealth
			success = true
		
	return success
	

#### DEAL TEMPORARY DAMAGE TO A CARD
func handleInflict(target:Card, amount:int):
	target.takeDamage(amount)
		


#### DEAL TEMPORARY AND PERMANENT DAMAGE TO A CARD
func handleCorrode(target:Card, amount:int):
	#target.tempHealth -= amount
	target.health -= amount
	
	if target.tempHealth <= 0:
		target.destroyAndAnimate(true, false)
		
		
	
	
	
	
	
