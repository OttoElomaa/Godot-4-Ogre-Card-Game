extends Node2D





#### DEAL TEMPORARY DAMAGE TO A CARD
func inflict(target:Card, amount:int):
	target.tempHealth -= amount
	
	if target.tempHealth <= 0:
		target.destroyAndAnimate(true)
		


#### DEAL TEMPORARY AND PERMANENT DAMAGE TO A CARD
func corrode(target:Card, amount:int):
	#target.tempHealth -= amount
	target.health -= amount
	
	if target.tempHealth <= 0:
		target.destroyAndAnimate(true)
		
		
		
		
		
		
		
