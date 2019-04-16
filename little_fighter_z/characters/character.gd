extends KinematicBody

class_name Character

export(float) var walk_speed: float = 2
export(float) var run_speed: float = 4

enum State {REST, WALK, RUN, PAIN}

enum ComboKey {NONE, UP, DOWN, LEFT, RIGHT, ATTACK, DEFEND, JUMP}

enum {
	U = ComboKey.UP,
	D = ComboKey.DOWN,
	L = ComboKey.LEFT,
	R = ComboKey.RIGHT,
	A = ComboKey.ATTACK,
	B = ComboKey.DEFEND,
	C = ComboKey.JUMP,
	UU = (U << 3) | U,
	DD = (D << 3) | D,
	LL = (L << 3) | L,
	RR = (R << 3) | R,
	UUU = (UU << 3) | U,
	DDD = (DD << 3) | D,
	LLL = (LL << 3) | L,
	RRR = (RR << 3) | R,
}

onready var animation_player := $AnimationPlayer as AnimationPlayer
onready var sprite_3d := $Sprite3D as Sprite3D

var state : int = State.REST
var velocity := Vector3()
var velocity_request := Vector3()

func _ready():
	animation_player.play("Rest")

func _physics_process(delta : float):
	if state == State.WALK and velocity_request.x == 0 and velocity_request.z == 0:
		change_state(State.REST)
	match state:
		State.WALK:
			velocity = move_and_slide(velocity_request.normalized() * walk_speed)
		State.RUN:
			velocity_request.x = sign(velocity.x)
			velocity = move_and_slide(velocity_request.normalized() * run_speed)
	if velocity.x != 0 or velocity.z != 0:
		if velocity.x < 0:
			sprite_3d.flip_h = true
		elif velocity.x > 0:
			sprite_3d.flip_h = false
	
func change_state(new_state : int) -> void:
	if state == new_state:
		return
	state = new_state
	match state:
		State.REST:
			animation_player.play("Rest")
		State.WALK:
			animation_player.play("Walk")
		State.RUN:
			animation_player.play("Run")
		State.PAIN:
			animation_player.play("Pain")


func input_combo(combo_code : int) -> void:
	match combo_code:
		U, D, L, R, UU, UUU, DD, DDD:
			_combo_walk(combo_code)
		LL, LLL, RR, RRR:
			_combo_run(combo_code)

func _combo_walk(combo_code : int) -> void:
	match state:
		State.REST, State.WALK:
			change_state(State.WALK)
		State.RUN:
			match combo_code:
				L, LL, LLL:
					if velocity.x > 0:
						change_state(State.WALK)
				R, RR, RRR:
					if velocity.x < 0:
						change_state(State.WALK)
	
func _combo_run(combo_code : int) -> void:
	match state:
		State.REST, State.WALK, State.RUN:
			match combo_code:
				LL, LLL:
					velocity = Vector3.LEFT
				RR, RRR:
					velocity = Vector3.RIGHT
			change_state(State.RUN)