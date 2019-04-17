extends KinematicBody

class_name Character

export(float) var walk_speed: float = 2.5
export(float) var run_speed: float = 5
export(float) var double_jump_time_window : float = 0.3
export(Vector2) var jump_velocity := Vector2(4, 11)
export(Vector2) var dash_velocity := Vector2(8, 8)
export(float) var gravity : float = -30

enum State {WALK, RUN, JUMP, DASH, PAIN}

onready var sprite_3d := $Sprite3D as Sprite3D
onready var animation_player := $AnimationPlayer as AnimationPlayer
onready var dash_land_duration := animation_player.get_animation("DashLand").length

var state : int = State.WALK
var velocity := Vector3()
var velocity_request := Vector3()
var double_jump := Vector3()

func _ready():
	animation_player.play("Rest")

func _physics_process(delta : float):
	velocity.y += gravity * delta
	match state:
		State.WALK:
			if velocity_request.x == 0 and velocity_request.z == 0:
				if animation_player.current_animation == "Walk":
					animation_player.play("Rest")
			else:
				if animation_player.current_animation == "Rest":
					animation_player.play("Walk")
				velocity = move_and_slide(velocity_request.normalized() * walk_speed, Vector3.UP)
		State.RUN:
			velocity_request.x = sign(velocity.x)
			velocity = move_and_slide(velocity_request.normalized() * run_speed, Vector3.UP)
		State.JUMP:
			velocity = move_and_slide(velocity, Vector3.UP)
			if is_on_floor() and not animation_player.is_playing():
				velocity = Vector3.ZERO
				animation_player.play_backwards("Jump")
		State.DASH:
			velocity = move_and_slide(velocity, Vector3.UP)
			if is_on_floor():
				change_state(State.WALK)
			elif (velocity.y + 0.5 * gravity * dash_land_duration) * dash_land_duration + translation.y < 0:
				animation_player.play("DashLand")
	match state:
		State.WALK, State.JUMP:
			if velocity_request.x != 0 or velocity_request.z != 0:
				if velocity_request.x < 0:
					sprite_3d.flip_h = true
				elif velocity_request.x > 0:
					sprite_3d.flip_h = false
		State.RUN, State.DASH:
			sprite_3d.flip_h = velocity.x < 0

func _on_AnimationPlayer_animation_finished(anim_name : String):
	match anim_name:
		"Jump":
			if animation_player.current_animation_position > 0: 
				velocity.y = 0
				velocity = velocity_request.normalized() * jump_velocity.x
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
		State.WALK:
			if velocity_request.x == 0 and velocity_request.z == 0:
				animation_player.play("Rest")
			else:
				animation_player.play("Walk")
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
			if (combo[-1] == '<' and velocity.x > 0) or \
					(combo[-1] == '>' and velocity.x < 0):
				change_state(State.WALK)

func _combo_run(combo : String) -> void:
	match state:
		State.WALK, State.RUN:
			match combo[-1]:
				'<':
					velocity = Vector3.LEFT
				'>':
					velocity = Vector3.RIGHT
			change_state(State.RUN)
			
			
func _combo_jump(combo : String) -> void:
	match state:
		State.WALK:
			change_state(State.JUMP)
		State.RUN:
			velocity = velocity.normalized() * dash_velocity.x
			velocity.y = dash_velocity.y
			change_state(State.DASH)
		State.JUMP:
			if (velocity.y + 0.5 * gravity * double_jump_time_window) * double_jump_time_window + translation.y < 0:
				if velocity_request.x == 0 and velocity_request.z == 0 :
					double_jump = velocity
				else:
					double_jump = velocity_request
			if abs(double_jump.x) > 0.01:
				double_jump.y = 0
				double_jump = double_jump.normalized() * dash_velocity.x
				double_jump.y = dash_velocity.y