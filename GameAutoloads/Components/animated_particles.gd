extends Node2D
class_name AnimatedParticles

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func setupAndAnimate(targetPos:Vector2, texture:Texture):
	position = targetPos   #### MOVE TO TARGET CARD
	
	for sprite:Sprite2D in $Particles.get_children():
		sprite.texture = texture
	
	var newPos := Vector2(0,-200)	
	var tween = create_tween()
	tween.tween_property($Particles, "position", newPos , 2)
	$DoneTimer.start()


func timeoutAnimationDone() -> void:
	queue_free()
