extends GPUParticles2D

func _ready():
	emitting = true
	await finished
	queue_free()
