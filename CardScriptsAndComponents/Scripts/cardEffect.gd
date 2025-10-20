extends Node2D
class_name CardEffect

#### THIS IS A BASE CLASS ->
#### KEYWORDS AND EFFECT COUNTERS INHERIT FROM IT
#### MAIN POINT IS THAT IT'S TRANSFERABLE VIA applyEffect()

@export var isPermanent := false

var sourceCard: Card = null
var myCard: Card = null

@export var id: String
@export var description: String


func setup(holder: Card):
#	self.sourceCard = sourceC
	myCard = holder
	for child in get_children():
		if child.has_method('setup'):
			child.setup(myCard)
	
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



	
