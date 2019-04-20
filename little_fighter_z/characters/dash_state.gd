extends BaseState

export(Vector2) var velocity := Vector2(8, 8)
export(float) var brake : float = 50

func transition(dir_vector : Vector3) -> void:
	dir_vector.y = 0
	chr.velocity = dir_vector.normalized() * velocity.x
	chr.velocity.y = velocity.y
	chr.state = self
	
func _physics_process_state(delta : float) -> void:
	chr.velocity.y += chr.gravity * delta
	chr.velocity = chr.move_and_slide(chr.velocity, Vector3.UP)
	if chr.is_on_floor():
		chr.animation_player.play("DashBrake")
		var new_speed := chr.velocity.distance_to(Vector3.ZERO) -  brake * delta
		if new_speed > 0:
			chr.velocity = chr.velocity.normalized() * new_speed
		else:
			chr.walk_state.transition()
		return
	chr.set_sprite_direction(chr.control_direction.x)
	if chr.sprite_3d.flip_h == (chr.to_local_basis(chr.velocity).dot(Vector3.RIGHT) < 0):
		if chr.velocity.y > 0:
			chr.animation_player.play("Dash")
		else:
			chr.animation_player.play("DashLand")
	else:
		if chr.velocity.y > 0:
			chr.animation_player.play("DashBack")
		else:
			chr.animation_player.play("DashLandBack")