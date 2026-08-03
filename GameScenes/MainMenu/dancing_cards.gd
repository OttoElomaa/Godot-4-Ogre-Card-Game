extends Node2D

var main: Node = null

func _ready():
	pass
	
func initialize(Main:Node):
	main = Main
	var tween = get_tree().create_tween()
	
	$CardContainer.insert_card(random_card())
	
	var new_pos_y = randi_range(0, 700)
	var new_pos_x = randi_range(500, 1800)
	tween.tween_property($CardContainer, 'global_position', Vector2(new_pos_x, new_pos_y), 0.5)
	
	var new_rot = randf_range(20, -20)
	tween.parallel().tween_property($CardContainer, 'rotation_degrees', new_rot, 0.5)
	
	await tween.finished
	
	$CardContainer/PutDown.play()
	
	if randf() > 0.3:
		$TypewriterTextbox.hide()
	$TypewriterTextbox.text = $CardContainer.card.flavorText
	$TypewriterTextbox.global_position = Vector2(randi_range(500, 1100), 
	randi_range(0, 600))
	$TypewriterTextbox.rotation_degrees += randf_range(25, -25) 
	$TypewriterTextbox.start()
	
	
#	$AnimationPlayer.play("CardDance")
#	$AnimationPlayer.advance(randf_range(0, 13))

func put_on_top():
	main.put_on_top(self)

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
