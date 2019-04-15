extends KinematicBody

class_name Character

export(float) var walk_speed: float = 2
export(float) var run_speed: float = 4

enum ComboKey {NONE, UP, DOWN, LEFT, RIGHT, ATTACK, DEFEND, JUMP}

enum {
	U = ComboKey.UP,
	D = ComboKey.DOWN,
	L = ComboKey.LEFT,
	R = ComboKey.RIGHT,
	LL = (ComboKey.LEFT << 3) | ComboKey.LEFT,
	LLL = (LL << 3) | ComboKey.LEFT,
	RR = (ComboKey.RIGHT << 3) | ComboKey.RIGHT,
	RRR = (RR << 3) | ComboKey.RIGHT,
}

func combo_string(combo_code : int) -> String:
	var combo_string : String
	for i in range(3):
		match (combo_code >> ((2 - i) * 3)) & 0x7:
			0:
				combo_string += '_'
			1:
				combo_string += 'U'
			2:
				combo_string += 'D'
			3:
				combo_string += 'L'
			4:
				combo_string += 'R'
			5:
				combo_string += 'A'
			6:
				combo_string += 'D'
			7:
				combo_string += 'J'
	return combo_string

enum State {REST, WALK, RUN, PAIN}

onready var animation_player := $AnimationPlayer as AnimationPlayer
onready var sprite_3d := $Sprite3D as Sprite3D

var state := 0
var velocity := Vector3()
var velocity_request := Vector3()

func _process(delta : float):
	if state == State.WALK and velocity_request.x == 0 and velocity_request.z == 0:
		state = State.REST
	if velocity.x != 0 or velocity.z != 0:
		if velocity.x < 0:
			sprite_3d.flip_h = true
		elif velocity.x > 0:
			sprite_3d.flip_h = false
	match state:
		State.REST:
			animation_player.play("Rest")
		State.WALK:
			animation_player.play("Walk")
		State.RUN:
			animation_player.play("Run")
		
func _physics_process(delta : float):
	match state:
		State.WALK:
			velocity = move_and_slide(velocity_request.normalized() * walk_speed)
		State.RUN:
			velocity_request.x = sign(velocity.x)
			velocity = move_and_slide(velocity_request.normalized() * run_speed)

func input_combo(combo_code : int):
	print(combo_string(combo_code))
	match combo_code:
		U, D, L, R:
			_combo_walk(combo_code)
		LL, LLL, RR, RRR:
			_combo_run(combo_code)

func _combo_walk(combo_code):
	match state:
		State.REST, State.WALK:
			state = State.WALK
		State.RUN:
			match combo_code:
				L, LL, LLL:
					if velocity.x > 0:
						state = State.WALK
				R, RR, RRR:
					if velocity.x < 0:
						state = State.WALK
	
func _combo_run(combo_code):
	match state:
		State.REST, State.WALK, State.RUN:
			match combo_code:
				LL, LLL:
					velocity = Vector3.LEFT
				RR, RRR:
					velocity = Vector3.RIGHT
			state = State.RUN