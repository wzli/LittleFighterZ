extends KinematicBody

class_name Character

export(float) var walk_speed: float = 2.5
export(float) var run_speed: float = 5
export(float) var run_curve : float = 0.1

export(Vector2) var jump_velocity := Vector2(4, 11)
export(Vector2) var dash_velocity := Vector2(8, 8)

#To do: move to globals
export(float) var double_jump_time_window : float = 0.2
export(float) var gravity : float = -30
export(float) var input_angle : float = PI
export(bool) var classic_mode : bool = false

enum State {WALK, RUN, JUMP, DASH, PAIN}

onready var sprite_3d := $Sprite3D as Sprite3D
onready var animation_player := $AnimationPlayer as AnimationPlayer
onready var dash_land_duration := animation_player.get_animation("DashLand").length

var state : int = State.WALK
var velocity := Vector3()
var control_direction := Vector3()
var double_jump := Vector3()

func _ready():
	animation_player.play("Rest")

func _physics_process(delta : float):
	velocity.y += gravity * delta
	match state:
		State.WALK:
			if control_direction.x == 0 and control_direction.z == 0:
				animation_player.play("Rest")
			else:
				animation_player.play("Walk")
				velocity = move_and_slide(control_direction * walk_speed, Vector3.UP)
		State.RUN:
			if classic_mode:
				velocity = velocity.project(Vector3.RIGHT.rotated(Vector3.UP, input_angle)).normalized()
				velocity = move_and_slide((velocity + control_direction).normalized() * run_speed, Vector3.UP)
			else:
				velocity = move_and_slide((velocity + run_curve * control_direction).normalized() * run_speed, Vector3.UP)
		State.JUMP:
			velocity = move_and_slide(velocity, Vector3.UP)
			if is_on_floor() and not animation_player.is_playing():
				velocity = Vector3.ZERO
				animation_player.play_backwards("Jump")
		State.DASH:
			velocity = move_and_slide(velocity, Vector3.UP)
			if is_on_floor():
				velocity = Vector3.ZERO
				change_state(State.WALK)
					
	var scalar_control_direction := scalar_direction(control_direction)
	var scalar_velocity_direction := scalar_direction(velocity)
	match state:
		State.WALK, State.JUMP:
			if scalar_control_direction != 0:
				sprite_3d.flip_h = scalar_control_direction < 0
		State.RUN:
			if scalar_velocity_direction != 0:
				sprite_3d.flip_h = scalar_velocity_direction < 0
		State.DASH:
			if (velocity.y + 0.5 * gravity * dash_land_duration) * dash_land_duration + translation.y < 0:
				if animation_player.assigned_animation.match("*Reverse"):
					animation_player.play("DashLandReverse")
				else:
					animation_player.play("DashLand")
			elif scalar_control_direction != 0:
				if scalar_velocity_direction == 0:
					sprite_3d.flip_h = scalar_control_direction < 0
				else:
					if (scalar_control_direction < 0) != (scalar_velocity_direction < 0):
						sprite_3d.flip_h = scalar_control_direction < 0
						animation_player.play("DashJumpReverse")
					else:
						sprite_3d.flip_h = scalar_velocity_direction < 0
						animation_player.play("DashJump")

func scalar_direction(direction : Vector3) -> float:
	if direction.x == 0 and direction.z == 0:
		return 0.0
	return direction.dot(Vector3.RIGHT.rotated(Vector3.UP, input_angle))
	
func _on_AnimationPlayer_animation_finished(anim_name : String):
	match anim_name:
		"Jump":
			if animation_player.current_animation_position > 0: 
				velocity.y = 0
				velocity = control_direction * jump_velocity.x
				velocity.y = jump_velocity.y
			else:
				if double_jump.y > 0:
					velocity = double_jump
					double_jump = Vector3.ZERO
					change_state(State.DASH)
				else:
					change_state(State.WALK)

func change_state(new_state : int) -> void:
	if state == new_state:
		return
	match new_state:
		State.RUN:
			animation_player.play("Run")
		State.JUMP:
			animation_player.play("Jump")
		State.DASH:
			animation_player.play("DashJump")
		State.PAIN:
			animation_player.play("Pain")
	state = new_state
	
func input_combo(combo : String) -> void:
	if combo[0] == 'D':
		match combo.right(1):
			'JA', 'AJ':
				pass
			'^A', 'A^':
				pass
			'vA', 'Av':
				pass
			'^J', 'J^':
				pass
			'vJ', 'Jv':
				pass
			'<A', 'A<', '>A', 'A>':
				pass
			'<J', 'J<', '>J', 'J>':
				pass
	elif combo.match('*<<') or combo.match('*>>'):
		_combo_run(combo)
	elif not classic_mode and (combo.match('*^^') or combo.match('*vv')):
		_combo_run(combo)
	else:
		match combo[-1]:
			'A':
				pass
			'J':
				_combo_jump(combo)
			'D':
				pass
			'^', 'v', '<', '>':
				_combo_walk(combo)

func _combo_walk(combo : String) -> void:
	match state:
		State.RUN:
			var local_angle := Vector2(velocity.x, velocity.z).angle() - input_angle + (2 * PI)
			if ((combo[-1] == '<' and (local_angle < 0.25 * PI or local_angle > 1.75 * PI))
					or (combo[-1] == '^' and (local_angle > 0.25 * PI and local_angle < 0.75 * PI))
					or (combo[-1] == '>' and (local_angle > 0.75 * PI and local_angle < 1.25 * PI))
					or (combo[-1] == 'v' and (local_angle > 1.25 * PI and local_angle < 1.75 * PI))):
						velocity = Vector3.ZERO
						change_state(State.WALK)

func _combo_run(combo : String) -> void:
	match state:
		State.WALK, State.RUN:
			match combo[-1]:
				'<':
					velocity = Vector3.LEFT.rotated(Vector3.UP, input_angle)
				'>':
					velocity = Vector3.RIGHT.rotated(Vector3.UP, input_angle)
				'^':
					velocity = Vector3.FORWARD.rotated(Vector3.UP, input_angle)
				'v':
					velocity = Vector3.BACK.rotated(Vector3.UP, input_angle)
			change_state(State.RUN)
			
			
func _combo_jump(combo : String) -> void:
	match state:
		State.WALK:
			velocity = Vector3.ZERO
			change_state(State.JUMP)
		State.RUN:
			velocity = velocity.normalized() * dash_velocity.x
			velocity.y = dash_velocity.y
			change_state(State.DASH)
		State.JUMP:
			if (velocity.y + 0.5 * gravity * double_jump_time_window) * double_jump_time_window + translation.y < 0:
				if control_direction.x == 0 and control_direction.z == 0 :
					double_jump = velocity
				else:
					double_jump = control_direction
			if abs(double_jump.x) > 0.01 or (not classic_mode and abs(double_jump.z) > 0.01):
				double_jump.y = 0
				double_jump = double_jump.normalized() * dash_velocity.x
				double_jump.y = dash_velocity.y