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
		
		if not target:
			continue
			
		#### INFLICT
		if inflictCreature > 0:
			var damage = inflictCreature
			if isScaled():
				damage = get_scaling({'target': target})
			await handleInflict(target, damage)
			MyTools.createCombatLogPrintout(str(target.cardName, '  suffers', damage, ' damage.'), Color.STEEL_BLUE)
			success = true

		#### CORRODE
		elif corrode > 0:
			var damage = corrode
			if isScaled():
				damage = get_scaling({'target': target})
			await handleCorrode(target, damage)
			MyTools.createCombatLogPrintout(str(target.cardName, '  is corroded for ', damage, ' damage.'), Color.STEEL_BLUE)
			success = true
		
		#### BOLSTER
		elif bolsterDamage > 0 or bolsterHealth > 0:
			target.tempDamage += bolsterDamage
			target.tempHealth += bolsterHealth
			MyTools.createCombatLogPrintout(str(target.cardName, ' gains +', bolsterDamage, '/', bolsterHealth), Color.STEEL_BLUE)
			success = true
		
	return success
	

#### DEAL TEMPORARY DAMAGE TO A CARD
func handleInflict(target:Card, amount:int):
	target.takeDamage(amount)
	target.checkAndHandleDeathFromTempHealth()
		


#### DEAL TEMPORARY AND PERMANENT DAMAGE TO A CARD
func handleCorrode(target:Card, amount:int):
	#target.tempHealth -= amount
	target.takeDamage(amount)
	target.health -= amount

		
	
	
	
	
	
