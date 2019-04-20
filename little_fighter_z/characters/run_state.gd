extends BaseState

export(float) var speed : float = 5
export(float) var curve : float = 0.1
export(float) var brake : float = 20

const ONE_OVER_SQRT_TWO := 1/sqrt(2)
	
func transition(direction_vector : Vector3) -> void:
	chr.velocity = chr.to_global_basis(direction_vector)
	chr.animation_player.play("Run")
	chr.set_sprite_direction(direction_vector.x)
	chr.state = self
	
func _physics_process_state(delta : float) -> void:
	if chr.animation_player.assigned_animation == "RunBrake":
		var new_speed := chr.velocity.distance_to(Vector3.ZERO) -  brake * delta
		if new_speed > 0:
			chr.velocity = chr.move_and_slide(chr.velocity.normalized() * new_speed, Vector3.UP)
		else:
			chr.walk_state.transition()
	elif chr.side_scroll_mode:
		chr.velocity = chr.velocity.project(chr.to_global_basis(Vector3.RIGHT)).normalized()
		chr.velocity = chr.move_and_slide((chr.velocity + 0.99 * chr.to_global_basis(chr.control_direction)).normalized() * speed, Vector3.UP)
	else:
		chr.velocity = chr.move_and_slide((chr.velocity + curve * chr.to_global_basis(chr.control_direction)).normalized() * speed, Vector3.UP)
		chr.set_sprite_direction(chr.to_local_basis(chr.velocity).dot(Vector3.RIGHT))
		
func _move(dir : int) -> void:
	if chr.velocity.normalized().dot(chr.to_global_basis(chr.control_direction)) < -ONE_OVER_SQRT_TWO:
		chr.animation_player.play("RunBrake")
					
func _jump() -> void:
	chr.dash_state.transition(chr.velocity)