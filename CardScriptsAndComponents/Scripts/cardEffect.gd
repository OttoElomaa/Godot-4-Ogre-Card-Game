extends Node2D
class_name CardEffect



@export var isPermanent := false

var sourceCard: Card = null
var myCard: Card = null





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


#### INHERITED FUNCTION -> EMPTY HERE, FILLED IN INHERITED CLASSES
func getEffectName():
	pass



	
