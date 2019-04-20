extends BaseState

export(Vector2) var velocity := Vector2(8, 8)
export(float) var brake : float = 50
export(float) var land_animation_ratio : float = 0.4

export(String) var animation := "Dash"
export(String) var back_animation := "DashBack"
export(String) var land_animation := "DashLand"
export(String) var land_back_animation := "DashLandBack"
export(String) var brake_animation := "DashBrake"

func transition(global_dir_vector : Vector3) -> void:
	chr.velocity = global_dir_vector.normalized() * velocity.x
	chr.velocity.y = velocity.y
	chr.state = self
	
func _physics_process_state(delta : float) -> void:
	chr.velocity.y += Config.gravity * delta
	chr.velocity = chr.move_and_slide(chr.velocity, Vector3.UP)
	if chr.is_on_floor():
		chr.animation_player.play(brake_animation)
		if chr.apply_brake_impulse(brake * delta):
			chr.walk_state.transition()
		return
	chr.set_sprite_direction(chr.control_direction.x)
	var local_speed := chr.to_local_basis(chr.velocity).dot(Vector3.RIGHT)
	if local_speed == 0 or (chr.sprite_3d.flip_h == (local_speed < 0)):
		if chr.velocity.y > (land_animation_ratio - 1) * velocity.y:
			chr.animation_player.play(animation)
		else:
			chr.animation_player.play(land_animation)
	else:
		if chr.velocity.y > (land_animation_ratio - 1) * velocity.y:
			chr.animation_player.play(back_animation)
		else:
			chr.animation_player.play(land_back_animation)