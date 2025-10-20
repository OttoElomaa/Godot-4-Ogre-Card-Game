extends ScalingComponent
@export var EffectId: String

## 'target': card whose effects need to be checked for the effect in EffectScene.
func get_scaling(args:Dictionary) -> int:
	var referred_card:Card = args['target']
	if referred_card.hasEffect(EffectId):
		return referred_card.getEffect(EffectId).counter
	else:
		return 0
