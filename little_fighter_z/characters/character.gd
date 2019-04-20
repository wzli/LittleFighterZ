extends KinematicBody
class_name Character

#To do: move to globals

export(float) var gravity : float = -30
export(bool) var side_scroll_mode : bool = false

onready var camera_anchor := $CameraAnchor as Position3D
onready var sprite_3d := $Sprite3D as Sprite3D
onready var animation_player := $AnimationPlayer as AnimationPlayer
onready var dash_land_duration := animation_player.get_animation("DashLand").length

var velocity := Vector3()
var control_direction := Vector3()

enum {UP_DIR, DOWN_DIR, LEFT_DIR, RIGHT_DIR}
onready var walk_state := $WalkState
onready var run_state := $RunState
onready var jump_state := $JumpState
onready var dash_state = $DashState
onready var state :=  walk_state

func _ready() -> void:
	camera_anchor.look_at(self.translation, Vector3.UP)

func _process(delta : float) -> void:
	state._process_state(delta)

func _physics_process(delta : float) -> void:
	state._physics_process_state(delta)
	
func _animation_finished(anim_name : String) -> void:
	state._animation_finished(anim_name)

func to_local_basis(vector : Vector3) -> Vector3:
	return global_transform.basis.xform_inv(vector)

func to_global_basis(vector : Vector3) -> Vector3:
	return global_transform.basis.xform(vector)
	
func set_sprite_direction(scalar_direction : float) -> void:
	if scalar_direction != 0:
		sprite_3d.flip_h = scalar_direction < 0
	
func input_combo(combo : String) -> void:
	if combo[1] == 'D':
		if side_scroll_mode:
			match combo.right(2):
				'JA', 'AJ':
					state._defend_attack_jump_combo()
				'^A', 'A^':
					state._up_attack_combo()
				'vA', 'Av':
					state._down_attack_combo()
				'^J', 'J^':
					state._up_jump_combo()
				'vJ', 'Jv':
					state._down_jump_combo()
				'<A', 'A<':
					state._side_attack_combo(LEFT_DIR)
				'>A', 'A>':
					state._side_attack_combo(RIGHT_DIR)
				'<J', 'J<':
					state._side_jump_combo(LEFT_DIR)
				'>J', 'J>':
					state._side_jump_combo(RIGHT_DIR)
		else:
			match combo.right(2):
				'JA', 'AJ':
					state._defend_attack_jump_combo()
				'^A', 'A^':
					if combo[0] == 'D':
						state._up_attack_combo()
					else:
						state._side_attack_combo(UP_DIR)
				'vA', 'Av':
					if combo[0] == 'D':
						state._down_attack_combo()
					else:
						state._side_attack_combo(DOWN_DIR)
				'<A', 'A<':
					state._side_attack_combo(LEFT_DIR)
				'>A', 'A>':
					state._side_attack_combo(RIGHT_DIR)
				'^J', 'J^':
					if combo[0] == 'D':
						state._up_jump_combo()
					else:
						state._side_jump_combo(UP_DIR)
				'vJ', 'Jv':
					if combo[0] == 'D':
						state._down_jump_combo()
					else:
						state._side_jump_combo(DOWN_DIR)
				'<J', 'J<':
					state._side_jump_combo(LEFT_DIR)
				'>J', 'J>':
					state._side_jump_combo(RIGHT_DIR)
	elif state._custom_combo(combo):
		pass
	elif not side_scroll_mode and combo.match('*^^'):
		state._run(UP_DIR)
	elif not side_scroll_mode and combo.match('*vv'):
		state._run(DOWN_DIR)
	elif combo.match('*<<'):
		state._run(LEFT_DIR)
	elif combo.match('*>>'):
		state._run(RIGHT_DIR)
	else:
		match combo[-1]:
			'A':
				state._attack()
			'J':
				state._jump()
			'D':
				state._defend()
			'^':
				state._move(UP_DIR)
			'v':
				state._move(DOWN_DIR)
			'<':
				state._move(LEFT_DIR)
			'>':
				state._move(RIGHT_DIR)