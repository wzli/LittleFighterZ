extends BaseState

export(Vector2) var velocity := Vector2(8, 8)

func transition(dir_vector : Vector3) -> void:
	dir_vector.y = 0
	chr.velocity = dir_vector.normalized() * velocity.x
	chr.velocity.y = velocity.y
	chr.state = self
	print("transition", chr.velocity)
	
func _physics_process_state(delta : float) -> void:
	chr.velocity.y += chr.gravity * delta
	chr.velocity = chr.move_and_slide(chr.velocity, Vector3.UP)
	if chr.is_on_floor():
		chr.walk_state.transition()
	chr.set_sprite_direction(chr.control_direction.x)
	var reverse := chr.sprite_3d.flip_h != (chr.to_local_basis(chr.velocity).dot(Vector3.RIGHT) < 0)
	if (chr.velocity.y + 0.5 * chr.gravity * chr.dash_land_duration) * chr.dash_land_duration + chr.translation.y < 0:
		if reverse:
			chr.animation_player.play("DashLandReverse")
		else:
			chr.animation_player.play("DashLand")
	else:
		if reverse:
			chr.animation_player.play("DashJumpReverse")
		else:
			chr.animation_player.play("DashJump")