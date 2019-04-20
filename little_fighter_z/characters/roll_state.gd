extends BaseState

export(float) var speed : float = 4
export(float) var duration : float = 0.4
export(float) var brake : float = 50

export(String) var animation := "Roll"
export(String) var brake_animation := "DashBrake"

var elapsed_time : float

func transition(global_direction_vector : Vector3) -> void:
	elapsed_time = 0
	global_direction_vector.y = 0
	chr.velocity = global_direction_vector.normalized() * speed
	chr.set_sprite_direction(chr.to_local_basis(global_direction_vector).x)
	chr.animation_player.play(animation)
	chr.state = self
	
func _physics_process_state(delta : float) -> void:
	chr.velocity = chr.move_and_slide(chr.velocity, Vector3.UP)
	elapsed_time += delta
	if elapsed_time > duration:
		chr.animation_player.play(brake_animation)
		if chr.apply_brake_impulse(brake * delta):
			chr.walk_state.transition()