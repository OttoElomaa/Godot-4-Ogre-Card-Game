extends Skill

@export var change_health = 0
@export var change_damage = 0

const gain_str = 'gains'
const lose_str = 'loses'

func get_str(number) -> String:
	if number >= 0:
		return gain_str
	else:
		return lose_str

func activate(targets:Array) -> bool:
	var success := false
	if isScaled():
		change_damage = get_scaling({})
		change_health = get_scaling({})
	for target:Card in targets:
		target.health += change_health
		target.damage += change_damage
		target.tempHealth += change_health
		target.tempDamage += change_damage
		target.updateCardVisuals()

	success = true
	return success
		
