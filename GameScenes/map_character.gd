extends CharacterBody2D

var movement_speed:float

func _physics_process(delta):
	
	$Camera2D.zoom = get_parent().zoom
	
	var current_agent_position = global_position
	var next_path_position = $NavigationAgent2D.get_next_path_position()
	var new_velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	
	if $NavigationAgent2D.is_navigation_finished():
		return
	
	if $NavigationAgent2D.avoidance_enabled:
		$NavigationAgent2D.set_velocity(new_velocity)
	else:
		velocity = new_velocity
	
	move_and_slide()
