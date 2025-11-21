extends PointLight2D

var orig_pos: Vector2
var orig_rot: float

func _ready():
	orig_pos = position
	orig_rot = rotation_degrees
	while is_inside_tree():
#		$Timer.wait_time = randf_range(0.06, 0.2)
#		position = get_new_pos()
		rotation_degrees = orig_rot + randf_range(-5, 5)
		texture_scale = 1.2 + randf_range(-0.5, 0.2)
		await $Timer.timeout
	
func get_new_pos():
	randomize()
	return orig_pos + Vector2(randi_range(-30, 30), randi_range(-30, 30))
