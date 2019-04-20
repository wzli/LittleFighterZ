extends BaseState

export(Vector2) var velocity := Vector2(4, 11)
export(float) var chain_time_window : float = 0.2

const MIN_CHAIN_SPEED := 0.01
var chain_velocity := Vector3()

func transition() -> void:
	chr.velocity = Vector3.ZERO
	chain_velocity = Vector3.ZERO
	chr.animations.play("Jump")
	chr.state = self
	
func set_chain_direction(vertical_direction : float) -> bool:
	if (chr.velocity.y + 0.5 * Config.gravity * chain_time_window) * chain_time_window + chr.translation.y < 0:
		if chr.control_direction.x == 0 and chr.control_direction.z == 0 :
			chain_velocity = chr.velocity
		else:
			chain_velocity = chr.to_global_basis(chr.control_direction)
		if abs(chain_velocity.x) > MIN_CHAIN_SPEED or (not Config.side_scroll_mode and abs(chain_velocity.z) > MIN_CHAIN_SPEED):
			chain_velocity.y = vertical_direction
			return true
		else:
			chain_velocity = Vector3.ZERO
	return false
	
func _physics_process_state(delta : float) -> void:
	chr.velocity.y += Config.gravity * delta
	chr.velocity = chr.move_and_slide(chr.velocity, Vector3.UP)
	chr.set_sprite_direction(chr.control_direction.x)
	if chr.is_on_floor() and not chr.animations.is_playing():
		if chain_velocity.y > 0:
			chr.dash_state.transition(chain_velocity)
		elif chain_velocity.y < 0:
			chr.roll_state.transition(chain_velocity)
		else:
			chr.velocity = Vector3.ZERO
			chr.animations.play_backwards("Jump")

func _animation_finished(anim_name : String) -> void:
	if chr.animations.current_animation_position > 0: 
		chr.velocity.y = 0
		chr.velocity = chr.to_global_basis(chr.control_direction) * velocity.x
		chr.velocity.y = velocity.y
	else:
		chr.walk_state.transition()
			
func _jump() -> void:
	set_chain_direction(1)
		
func _defend() -> void:
	set_chain_direction(-1)