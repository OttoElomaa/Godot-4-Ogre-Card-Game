extends Node2D

func _ready():
	pass
	
func initialize():
	$CardContainer.insert_card(random_card())
	$CardContainer.position.y += randi_range(200, -200)
	$CardContainer.rotation_degrees += randf_range(20, -20)
	
	if randf() > 0.3:
		$TypewriterTextbox.hide()
	$TypewriterTextbox.text = $CardContainer.card.flavorText
	if not screen_side_left() == 1:
		$TypewriterTextbox.position.x += -600
	$TypewriterTextbox.position += Vector2(randi_range(-10 * screen_side_left(), 100 * screen_side_left()), 
	randi_range(-200, 200))
	$TypewriterTextbox.rotation_degrees += randf_range(25, -25) 
	$TypewriterTextbox.start()
#	$AnimationPlayer.play("CardDance")
#	$AnimationPlayer.advance(randf_range(0, 13))

func random_card() -> Card:
	assert(not GameInfo.all_cards.is_empty(), "Why empty??")
	return GameInfo.all_cards[randi_range(0, GameInfo.all_cards.size() - 1)]

func screen_side_left():
	if global_position.x < 1000:
		return 1
	else:
		return -1

func _on_card_container_mouse_entered():
	$AnimationPlayer.speed_scale = 0.0

func _on_card_container_mouse_exited():
	$AnimationPlayer.speed_scale = 1.0
