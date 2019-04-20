extends BaseState

export(Vector2) var velocity := Vector2(8, 8)
export(float) var brake : float = 60

func transition(global_dir_vector : Vector3) -> void:
	chr.velocity = global_dir_vector.normalized() * velocity.x
	chr.velocity.y = velocity.y
	chr.state = self
	
func _physics_process_state(delta : float) -> void:
	chr.velocity.y += Config.gravity * delta
	chr.velocity = chr.move_and_slide(chr.velocity, Vector3.UP)
	if chr.is_on_floor():
		chr.animations.play("DashBrake")
		if chr.apply_brake_impulse(brake * delta):
			chr.walk_state.transition()
		return
	chr.set_sprite_direction(chr.control_direction.x)
	var local_speed := chr.to_local_basis(chr.velocity).dot(Vector3.RIGHT)
	if local_speed == 0 or (chr.sprite_3d.flip_h == (local_speed < 0)):
		if chr.velocity.y > 0:
			chr.animations.play("Dash")
		else:
			chr.animations.play("DashLand")
	else:
		if chr.velocity.y > 0:
			chr.animations.play("DashBack")
		else:
			chr.animations.play("DashLandBack")