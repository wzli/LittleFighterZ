extends KinematicBody

class_name Character

export(float) var walk_speed: float = 2.5
export(float) var run_speed: float = 5
export(Vector2) var jump_velocity := Vector2(4, 11)
export(float) var gravity : float = -30

enum State {REST, WALK, RUN, JUMP, PAIN}

onready var animation_player := $AnimationPlayer as AnimationPlayer
onready var sprite_3d := $Sprite3D as Sprite3D

var state : int = State.REST
var velocity := Vector3()
var velocity_request := Vector3()

func _ready():
	animation_player.play("Rest")

func _physics_process(delta : float):
	match state:
		State.REST:
			if velocity_request.x != 0 or velocity_request.z != 0:
				change_state(State.WALK)
		State.WALK:
			if velocity_request.x == 0 and velocity_request.z == 0:
				change_state(State.REST)
			else:
				velocity = move_and_slide(velocity_request.normalized() * walk_speed, Vector3.UP)
		State.RUN:
			velocity_request.x = sign(velocity.x)
			velocity = move_and_slide(velocity_request.normalized() * run_speed, Vector3.UP)
		State.JUMP:
			if is_on_floor() and velocity.y < jump_velocity.y:
				animation_player.play_backwards("Jump")
			else:
				velocity.y += gravity * delta
				velocity = move_and_slide(velocity, Vector3.UP)
	match state:
		State.REST, State.WALK:
			if velocity_request.x != 0 or velocity_request.z != 0:
				if velocity_request.x < 0:
					sprite_3d.flip_h = true
				elif velocity_request.x > 0:
					sprite_3d.flip_h = false
		State.RUN:
			sprite_3d.flip_h = velocity.x < 0

func _on_AnimationPlayer_animation_finished(anim_name : String):
	match anim_name:
		"Jump":
			match state:
				State.REST, State.WALK: 
					velocity = velocity_request.normalized() * jump_velocity.x
					velocity.y += jump_velocity.y
					change_state(State.JUMP)
				State.JUMP:
					if velocity_request.x == 0 && velocity_request.z == 0: 
						change_state(State.REST)
					else:
						change_state(State.WALK)

func change_state(new_state : int) -> void:
	if state == new_state:
		return
	match new_state:
		State.REST:
		    animation_player.play("Rest")
		State.WALK:
			animation_player.play("Walk")
		State.RUN:
			animation_player.play("Run")
		State.JUMP:
			pass
		State.PAIN:
			animation_player.play("Pain")
	state = new_state
	print(animation_player.assigned_animation)

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
		State.REST:
			change_state(State.WALK)
		State.RUN:
			if (combo[-1] == '<' and velocity.x > 0) or \
					(combo[-1] == '>' and velocity.x < 0):
				change_state(State.WALK)

func _combo_run(combo : String) -> void:
	match state:
		State.REST, State.WALK, State.RUN:
			match combo[-1]:
				'<':
					velocity = Vector3.LEFT
				'>':
					velocity = Vector3.RIGHT
			change_state(State.RUN)
			
func _combo_jump(combo : String) -> void:
	match state:
		State.REST, State.WALK:
			animation_player.play("Jump")