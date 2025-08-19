extends Node2D
class_name CardEffect


enum effectTypes {
	NONE, BUFF, DEBUFF
}

@export var effectType := effectTypes.NONE
@export var isPermanent := false

var sourceCard: Card = null
var myCard: Card = null


@export var hasDuelist := false
@export var hasVanguard := false


@export var isDoom := false
@export var isArmor := false


var icon:
	get:
		return $Icon.texture



func setup(sourceC:Card):
	self.sourceCard = sourceC
	
	



func applyEffect(targetCard:Card):
	
	#### CREATE COPY OF SELF
	var appliedEffect = self.duplicate()
	appliedEffect.setup(myCard)
	
	#### ATTACH COPY TO TARGET CREATURE
	targetCard.addEffect(appliedEffect)
	appliedEffect.setMyTarget(targetCard)


	
func setMyTarget(card:Card):
	self.myCard = card



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
	
