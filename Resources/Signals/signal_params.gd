extends Resource
class_name SignalParams

var sourceCard: Card = null
var targetCard: Card = null
var amount: int = 0
var isEnemySide := false

static func create(args:Dictionary[String, Variant]) -> SignalParams:
	var new = SignalParams.new()
	new.sourceCard = args['sourceCard']
	new.targetCard = args['targetCard']
	new.amount = args['amount']
	new.isEnemySide = args['isEnemySide']
	return new
