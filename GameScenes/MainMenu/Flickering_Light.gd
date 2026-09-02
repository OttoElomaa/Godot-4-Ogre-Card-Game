extends PointLight2D

@onready var orig_pos: Vector2 = position
@onready var orig_scale: float = texture_scale

func _ready():
	while is_inside_tree():
		var tween = get_tree().create_tween()
		tween.tween_property(self, "texture_scale", orig_scale + randf_range(0.0, 0.2), randf_range(0.3, 0.32))
		tween.parallel().tween_property(self, 'position', get_new_pos(), randf_range(0.01, 0.32))
		await tween.finished
	
func get_new_pos():
	return orig_pos + Vector2(randi_range(-10, 10), randi_range(-10, 10))
