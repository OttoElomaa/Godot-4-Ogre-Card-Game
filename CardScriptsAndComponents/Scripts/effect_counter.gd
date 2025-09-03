extends CardEffect



enum effectTypes {
	NONE, BUFF, DEBUFF
}
@export var effectType := effectTypes.NONE


var icon:
	get:
		return $Icon.texture


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
