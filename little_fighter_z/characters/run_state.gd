extends BaseState

export(float) var speed : float = 5
export(float) var curve : float = 0.1
export(float) var brake : float = 20

const ONE_OVER_SQRT_TWO := 1/sqrt(2)
	
func transition(direction_vector : Vector3) -> void:
	chr.velocity = chr.to_global_basis(direction_vector)
	chr.animations.play("Run")
	chr.set_sprite_direction(direction_vector.x)
	chr.state = self
	
func _physics_process_state(delta : float) -> void:
	chr.velocity = chr.move_and_slide(chr.velocity, Vector3.UP)
	if chr.animations.assigned_animation == "RunBrake":
		if chr.apply_brake_impulse(brake * delta):
			chr.walk_state.transition()
	elif Config.side_scroll_mode:
		chr.velocity = chr.velocity.project(chr.to_global_basis(Vector3.RIGHT)).normalized()
		chr.velocity +=  0.99 * chr.to_global_basis(chr.control_direction)
		chr.velocity = chr.velocity.normalized() * speed
	else:
		chr.velocity += curve * chr.to_global_basis(chr.control_direction)
		chr.velocity = chr.velocity.normalized() * speed
		chr.set_sprite_direction(chr.to_local_basis(chr.velocity).dot(Vector3.RIGHT))
		
func _move(dir : int) -> void:
	if chr.velocity.normalized().dot(chr.to_global_basis(chr.control_direction)) < -ONE_OVER_SQRT_TWO:
		chr.animations.play("RunBrake")

func _jump() -> void:
	chr.dash_state.transition(chr.velocity)
	
func _defend() -> void:
	chr.roll_state.transition(chr.velocity)