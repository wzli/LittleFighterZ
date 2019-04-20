extends BaseState

export(Vector2) var velocity := Vector2(4, 11)
export(float) var chain_time_window : float = 0.2

const MIN_CHAIN_SPEED := 0.01
var double_jump := Vector3()

func transition() -> void:
	chr.velocity = Vector3.ZERO
	chr.animation_player.play("Jump")
	chr.state = self
	
func _physics_process_state(delta : float) -> void:
	chr.velocity.y += Config.gravity * delta
	chr.velocity = chr.move_and_slide(chr.velocity, Vector3.UP)
	chr.set_sprite_direction(chr.control_direction.x)
	if chr.is_on_floor() and not chr.animation_player.is_playing():
		chr.velocity = Vector3.ZERO
		chr.animation_player.play_backwards("Jump")

func _animation_finished(anim_name : String) -> void:
	if chr.animation_player.current_animation_position > 0: 
		chr.velocity.y = 0
		chr.velocity = chr.to_global_basis(chr.control_direction) * velocity.x
		chr.velocity.y = velocity.y
	else:
		if double_jump.y > 0:
			chr.dash_state.transition(double_jump)
			double_jump = Vector3.ZERO
		else:
			chr.walk_state.transition()
			
func _jump() -> void:
	if (chr.velocity.y + 0.5 * Config.gravity * chain_time_window) * chain_time_window + chr.translation.y < 0:
		if chr.control_direction.x == 0 and chr.control_direction.z == 0 :
			double_jump = chr.velocity
		else:
			double_jump = chr.to_global_basis(chr.control_direction)
	if abs(double_jump.x) > MIN_CHAIN_SPEED or (not Config.side_scroll_mode and abs(double_jump.z) > MIN_CHAIN_SPEED):
		double_jump.y = 1