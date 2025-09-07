extends CardEffect
class_name EffectCounter


enum effectTypes {
	NONE, BUFF, DEBUFF
}
@export var effectType := effectTypes.NONE


var icon:
	get:
		return $Icon.texture

var counter: int
@export var max_counter: int

@export var isDoom := false

@export var isArmor := false
@export var isHunt := false


func getEffectName():
	if isDoom:
		return "Doom"
	if isArmor:
		return "Armor"

func toggleIcon(toShow:bool):
	if toShow:
		$Icon.show()
	else:
		$Icon.hide()
