extends Node

enum effectTypes {
	NONE, BUFF, DEBUFF
}

@export var effectType := effectTypes.NONE
@export var isPermanent := false

@export var sourceCard: Card = null
var myCard: Card = null


@export var hasDuelist := false
@export var hasVanguard := false



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
