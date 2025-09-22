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

func toggleIcon(toShow:bool):
	if toShow:
		$Icon.show()
	else:
		$Icon.hide()
