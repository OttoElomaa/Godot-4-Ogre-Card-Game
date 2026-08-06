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
		elif bolsterDamage > 0:
			if isScaled():
				bolsterDamage = get_scaling({'target': target})
			target.tempDamage += bolsterDamage
			
			if bolsterDamage > 0:
				MyTools.createCombatLogPrintout(str(target.cardName, "'s damage is bolstered by ", bolsterDamage), Color.STEEL_BLUE)
			elif bolsterDamage < 0:
				MyTools.createCombatLogPrintout(str(target.cardName, "'s damage is weakened by ", bolsterDamage), Color.STEEL_BLUE)
			
		elif bolsterHealth > 0:
			if isScaled():
				bolsterHealth = get_scaling({'target': target})
			target.tempHealth += bolsterHealth
			if bolsterHealth > 0:
				MyTools.createCombatLogPrintout(str(target.cardName, "'s health is bolstered by ", bolsterDamage), Color.STEEL_BLUE)
			elif bolsterHealth < 0:
				MyTools.createCombatLogPrintout(str(target.cardName, "'s health is weakened by ", bolsterDamage), Color.STEEL_BLUE)
			success = true
		
	return success
	

#### DEAL TEMPORARY DAMAGE TO A CARD
func handleInflict(target:Card, amount:int):
	target.takeDamage(amount)
	var died = target.checkAndHandleDeathFromTempHealth()
	if died:
		CardAnimationQueue.startResponseQueue()


#### DEAL TEMPORARY AND PERMANENT DAMAGE TO A CARD
func handleCorrode(target:Card, amount:int):
	#target.tempHealth -= amount
	target.takeDamage(amount)
	target.health -= amount
	var died = target.checkAndHandleDeathFromTempHealth()
	if died:
		CardAnimationQueue.startResponseQueue()
		
	
	
	
	
	
