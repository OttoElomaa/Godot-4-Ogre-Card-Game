extends "res://GameScenes/CardDisplayContainers/cardInfoPanel.gd"

@onready var size = $MarginWithOuter.size

func show_at(pos: Vector2):
	position = pos
	position.x = clamp(position.x, 0, get_viewport_rect().size.x - size.x)
	position.y = clamp(position.y, 0, get_viewport_rect().size.y - size.y)

	show()
