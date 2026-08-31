@icon('uid://btfn7s0yo33kt')
extends ZoneNode

@export var glory = 0

func _ready():
	super()
	node_comments = str('Pick up to gain ', glory, ' Glory')

func handleClick():
	GameInfo.playerGlory += glory
	resolve()
