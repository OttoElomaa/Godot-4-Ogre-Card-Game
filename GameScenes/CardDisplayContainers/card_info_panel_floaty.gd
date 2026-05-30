extends CardInfoPanel

func show_at(pos: Vector2):
	var screen_size = get_viewport().get_visible_rect().size
	position = pos
	if position.x > screen_size.x / 2:
		position.x -= size.x / 2
	if position.y > screen_size.y / 2:
		position.y -= size.y / 2

	show()
