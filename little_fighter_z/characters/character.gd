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
export(bool) var side_scroll_mode : bool = false

onready var sprite_3d := $Sprite3D as Sprite3D
onready var animation_player := $AnimationPlayer as AnimationPlayer
onready var dash_land_duration := animation_player.get_animation("DashLand").length

var velocity := Vector3()
var control_direction := Vector3()

enum {UP_DIR, DOWN_DIR, LEFT_DIR, RIGHT_DIR}
const WALK_STATE := 0
const RUN_STATE := 1
const JUMP_STATE := 2
const DASH_STATE := 3
var states := [WalkState.new(), RunState.new(), JumpState.new(), DashState.new()]
var state := WALK_STATE

func transition(new_state : int, param = null) -> void:
	states[new_state]._transition_setup(param)
	state = new_state

func _init():
	for state_obj in states:
		state_obj.chr = self

func _process(delta : float) -> void:
	states[state]._process(delta)

func _physics_process(delta : float) -> void:
	states[state]._physics_process(delta)
	
func _animation_finished(anim_name : String) -> void:
	states[state]._animation_finished(anim_name)

func to_local_basis(vector : Vector3) -> Vector3:
	return global_transform.basis.xform(vector)

func to_global_basis(vector : Vector3) -> Vector3:
	return global_transform.basis.xform_inv(vector)
	
func set_sprite_direction(scalar_direction : float) -> void:
	if scalar_direction != 0:
		sprite_3d.flip_h = scalar_direction < 0
	
func input_combo(combo : String) -> void:
	if combo[1] == 'D':
		if side_scroll_mode:
			match combo.right(2):
				'JA', 'AJ':
					states[state]._defend_attack_jump_combo()
				'^A', 'A^':
					states[state]._up_attack_combo()
				'vA', 'Av':
					states[state]._down_attack_combo()
				'^J', 'J^':
					states[state]._up_jump_combo()
				'vJ', 'Jv':
					states[state]._down_jump_combo()
				'<A', 'A<':
					states[state]._side_attack_combo(LEFT_DIR)
				'>A', 'A>':
					states[state]._side_attack_combo(RIGHT_DIR)
				'<J', 'J<':
					states[state]._side_jump_combo(LEFT_DIR)
				'>J', 'J>':
					states[state]._side_jump_combo(RIGHT_DIR)
		else:
			match combo.right(2):
				'JA', 'AJ':
					states[state]._defend_attack_jump_combo()
				'^A', 'A^':
					if combo[0] == 'D':
						states[state]._up_attack_combo()
					else:
						states[state]._side_attack_combo(UP_DIR)
				'vA', 'Av':
					if combo[0] == 'D':
						states[state]._down_attack_combo()
					else:
						states[state]._side_attack_combo(DOWN_DIR)
				'<A', 'A<':
					states[state]._side_attack_combo(LEFT_DIR)
				'>A', 'A>':
					states[state]._side_attack_combo(RIGHT_DIR)
				'^J', 'J^':
					if combo[0] == 'D':
						states[state]._up_jump_combo()
					else:
						states[state]._side_jump_combo(UP_DIR)
				'vJ', 'Jv':
					if combo[0] == 'D':
						states[state]._down_jump_combo()
					else:
						states[state]._side_jump_combo(DOWN_DIR)
				'<J', 'J<':
					states[state]._side_jump_combo(LEFT_DIR)
				'>J', 'J>':
					states[state]._side_jump_combo(RIGHT_DIR)
	elif states[state]._custom_combo(combo):
		pass
	elif not side_scroll_mode and combo.match('*^^'):
		states[state]._run(UP_DIR)
	elif not side_scroll_mode and combo.match('*vv'):
		states[state]._run(DOWN_DIR)
	elif combo.match('*<<'):
		states[state]._run(LEFT_DIR)
	elif combo.match('*>>'):
		states[state]._run(RIGHT_DIR)
	else:
		match combo[-1]:
			'A':
				states[state]._attack()
			'J':
				states[state]._jump()
			'D':
				states[state]._defend()
			'^':
				states[state]._move(UP_DIR)
			'v':
				states[state]._move(DOWN_DIR)
			'<':
				states[state]._move(LEFT_DIR)
			'>':
				states[state]._move(RIGHT_DIR)

class BaseState:
	var chr : Character
	func _transition_setup(param) -> void:
		pass
	func _process(delta : float) -> void:
		pass
	func _physics_process(delta : float) -> void:
		pass
	func _animation_finished(anim_name : String) -> void:
		pass
	func _move(dir : int) -> void:
		pass
	func _run(dir : int) -> void:
		pass
	func _attack() -> void:
		pass
	func _jump() -> void:
		pass
	func _defend() -> void:
		pass
	func _side_attack_combo(dir : int) -> void:
		pass
	func _side_jump_combo(dir : int) -> void:
		pass
	func _up_attack_combo() -> void:
		pass
	func _up_jump_combo() -> void:
		pass
	func _down_attack_combo() -> void:
		pass
	func _down_jump_combo() -> void:
		pass
	func _defend_attack_jump_combo() -> void:
		pass
	func _custom_combo(combo : String) -> bool:
		# return true if combo was handled
		return false

class WalkState extends BaseState:
	
	func _transition_setup(param) -> void:
		chr.velocity = Vector3.ZERO

	func _physics_process(delta : float) -> void:
		if chr.control_direction.x == 0 and chr.control_direction.z == 0:
			chr.animation_player.play("Rest")
		else:
			chr.animation_player.play("Walk")
			chr.velocity = chr.move_and_slide(chr.to_global_basis(chr.control_direction) * chr.walk_speed, Vector3.UP)
		chr.set_sprite_direction(chr.control_direction.x)
	
	func _run(dir : int) -> void:
		chr.transition(RUN_STATE, chr.control_direction)
		
	func _jump() -> void:
		chr.transition(JUMP_STATE)

class RunState extends BaseState:
	const ONE_OVER_SQRT_TWO := 1/sqrt(2)
	
	func _transition_setup(direction_vector : Vector3) -> void:
		chr.velocity = chr.to_global_basis(direction_vector)
		chr.animation_player.play("Run")
		chr.set_sprite_direction(direction_vector.x)
		
	func _physics_process(delta : float) -> void:
		if chr.side_scroll_mode:
			chr.velocity = chr.velocity.project(chr.to_global_basis(Vector3.RIGHT)).normalized()
			chr.velocity = chr.move_and_slide((chr.velocity + 0.99 * chr.to_global_basis(chr.control_direction)).normalized() * chr.run_speed, Vector3.UP)
		else:
			chr.velocity = chr.move_and_slide((chr.velocity + chr.run_curve * chr.to_global_basis(chr.control_direction)).normalized() * chr.run_speed, Vector3.UP)
			chr.set_sprite_direction(chr.to_local_basis(chr.velocity).dot(Vector3.RIGHT))
			
	func _move(dir : int) -> void:
		if chr.velocity.normalized().dot(chr.to_global_basis(chr.control_direction)) < -ONE_OVER_SQRT_TWO:
			chr.transition(WALK_STATE)
						
	func _jump() -> void:
		chr.transition(DASH_STATE, chr.velocity)
		
class JumpState extends BaseState:
	var double_jump := Vector3()
	
	func _transition_setup(param) -> void:
		chr.velocity = Vector3.ZERO
		chr.animation_player.play("Jump")
		
	func _physics_process(delta : float) -> void:
		chr.velocity.y += chr.gravity * delta
		chr.velocity = chr.move_and_slide(chr.velocity, Vector3.UP)
		if chr.is_on_floor() and not chr.animation_player.is_playing():
			chr.velocity = Vector3.ZERO
			chr.animation_player.play_backwards("Jump")
		chr.set_sprite_direction(chr.control_direction.x)
		
	func _animation_finished(anim_name : String) -> void:
		if anim_name != "Jump":
			return
		if chr.animation_player.current_animation_position > 0: 
			chr.velocity.y = 0
			chr.velocity = chr.to_global_basis(chr.control_direction) * chr.jump_velocity.x
			chr.velocity.y = chr.jump_velocity.y
		else:
			if double_jump.y > 0:
				chr.transition(DASH_STATE, double_jump)
				double_jump = Vector3.ZERO
			else:
				chr.transition(WALK_STATE)
				
	func _jump() -> void:
		if (chr.velocity.y + 0.5 * chr.gravity * chr.double_jump_time_window) * chr.double_jump_time_window + chr.translation.y < 0:
			if chr.control_direction.x == 0 and chr.control_direction.z == 0 :
				double_jump = chr.velocity
			else:
				double_jump = chr.to_global_basis(chr.control_direction)
		if abs(double_jump.x) > 0.01 or (not chr.side_scroll_mode and abs(double_jump.z) > 0.01):
			double_jump.y = 1
				
class DashState extends BaseState:
	
	func _transition_setup(dir_vector : Vector3) -> void:
		dir_vector.y = 0
		chr.velocity = dir_vector.normalized() * chr.dash_velocity.x
		chr.velocity.y = chr.dash_velocity.y
		
	func _physics_process(delta : float) -> void:
		chr.velocity.y += chr.gravity * delta
		chr.velocity = chr.move_and_slide(chr.velocity, Vector3.UP)
		if chr.is_on_floor():
			print(chr.animation_player.assigned_animation)
			chr.transition(WALK_STATE)
		chr.set_sprite_direction(chr.control_direction.x)
		var reverse := chr.sprite_3d.flip_h != (chr.to_local_basis(chr.velocity).dot(Vector3.RIGHT) < 0)
		if (chr.velocity.y + 0.5 * chr.gravity * chr.dash_land_duration) * chr.dash_land_duration + chr.translation.y < 0:
			if reverse:
				chr.animation_player.play("DashLandReverse")
			else:
				chr.animation_player.play("DashLand")
		else:
			if reverse:
				chr.animation_player.play("DashJumpReverse")
			else:
				chr.animation_player.play("DashJump")