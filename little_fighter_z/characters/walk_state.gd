extends BaseState

export(float) var speed : float = 2.5
export(String) var animation := "Walk"
export(String) var rest_animation := "WalkRest"

func transition() -> void:
	chr.velocity = Vector3.ZERO
	chr.state = self

func _physics_process_state(delta : float) -> void:
	if chr.control_direction.x == 0 and chr.control_direction.z == 0:
		chr.animation_player.play(rest_animation)
		return
	chr.velocity = chr.move_and_slide(chr.to_global_basis(chr.control_direction) * speed, Vector3.UP)
	chr.set_sprite_direction(chr.control_direction.x)
	chr.animation_player.play(animation)

func _run(dir : int) -> void:
	chr.run_state.transition(chr.control_direction)
	
func _jump() -> void:
	chr.jump_state.transition()