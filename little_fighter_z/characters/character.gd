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
export(bool) var classic_mode : bool = true

onready var sprite_3d := $Sprite3D as Sprite3D
onready var animation_player := $AnimationPlayer as AnimationPlayer
onready var dash_land_duration := animation_player.get_animation("DashLand").length

var velocity := Vector3()
var control_direction := Vector3()
var double_jump := Vector3()
var state = WalkState

func _physics_process(delta : float) -> void:
	#velocity.y += gravity * delta
	state._physics_process(self, delta)

func scalar_direction(direction : Vector3) -> float:
	if direction.x == 0 and direction.z == 0:
		return 0.0
	return direction.dot(Vector3.RIGHT.rotated(Vector3.UP, input_angle))
	
func input_combo(combo : String) -> void:
	if combo[1] == 'D':
		if classic_mode:
			match combo.right(2):
				'JA', 'AJ':
					state._defend_attack_jump_combo(self)
				'^A', 'A^':
					state._up_attack_combo(self)
				'vA', 'Av':
					state._down_attack_combo(self)
				'^J', 'J^':
					state._up_jump_combo(self)
				'vJ', 'Jv':
					state._down_jump_combo(self)
				'<A', 'A<':
					state._side_attack_combo(self, BaseState.LEFT_DIR)
				'>A', 'A>':
					state._side_attack_combo(self, BaseState.RIGHT_DIR)
				'<J', 'J<':
					state._side_jump_combo(self, BaseState.LEFT_DIR)
				'>J', 'J>':
					state._side_jump_combo(self, BaseState.RIGHT_DIR)
		else:
			match combo.right(2):
				'JA', 'AJ':
					state._defend_attack_jump_combo(self)
				'^A', 'A^':
					if combo[0] == 'D':
						state._up_attack_combo(self)
					else:
						state._side_attack_combo(self, BaseState.UP_DIR)
				'vA', 'Av':
					if combo[0] == 'D':
						state._down_attack_combo(self)
					else:
						state._side_attack_combo(self, BaseState.DOWN_DIR)
				'<A', 'A<':
					state._side_attack_combo(self, BaseState.LEFT_DIR)
				'>A', 'A>':
					state._side_attack_combo(self, BaseState.RIGHT_DIR)
				'^J', 'J^':
					if combo[0] == 'D':
						state._up_jump_combo(self)
					else:
						state._side_jump_combo(self, BaseState.UP_DIR)
				'vJ', 'Jv':
					if combo[0] == 'D':
						state._down_jump_combo(self)
					else:
						state._side_jump_combo(self, BaseState.DOWN_DIR)
				'<J', 'J<':
					state._side_jump_combo(self, BaseState.LEFT_DIR)
				'>J', 'J>':
					state._side_jump_combo(self, BaseState.RIGHT_DIR)
	elif state._custom_combo(self, combo):
		pass
	elif not classic_mode and combo.match('*^^'):
		state._run(self, BaseState.UP_DIR)
	elif not classic_mode and combo.match('*vv'):
		state._run(self, BaseState.DOWN_DIR)
	elif combo.match('*<<'):
		state._run(self, BaseState.LEFT_DIR)
	elif combo.match('*>>'):
		state._run(self, BaseState.RIGHT_DIR)
	else:
		match combo[-1]:
			'A':
				state._attack(self)
			'J':
				state._jump(self)
			'D':
				state._defend(self)
			'^':
				state._move(self, BaseState.UP_DIR)
			'v':
				state._move(self, BaseState.DOWN_DIR)
			'<':
				state._move(self, BaseState.LEFT_DIR)
			'>':
				state._move(self, BaseState.RIGHT_DIR)

func transition(new_state) -> void:
	new_state._transition_setup(self)
	state = new_state

class BaseState:
	enum {UP_DIR, DOWN_DIR, LEFT_DIR, RIGHT_DIR}
	static func _transition_setup(chr : Character) -> void:
		pass
	static func _physics_process(chr : Character, delta : float) -> void:
		pass
	static func _animation_finished(chr : Character, anim_name : String) -> void:
		pass
	static func _move(chr : Character, dir : int) -> void:
		pass
	static func _run(chr : Character, dir : int) -> void:
		pass
	static func _attack(chr : Character) -> void:
		pass
	static func _jump(chr : Character) -> void:
		pass
	static func _defend(chr : Character) -> void:
		pass
	static func _side_attack_combo(chr : Character, dir : int) -> void:
		pass
	static func _side_jump_combo(chr : Character, dir : int) -> void:
		pass
	static func _up_attack_combo(chr : Character) -> void:
		pass
	static func _up_jump_combo(chr : Character) -> void:
		pass
	static func _down_attack_combo(chr : Character) -> void:
		pass
	static func _down_jump_combo(chr : Character) -> void:
		pass
	static func _defend_attack_jump_combo(chr : Character) -> void:
		pass
	static func _custom_combo(chr : Character, combo : String) -> bool:
		# return true if combo was handled
		return false

class WalkState extends BaseState:
	
	static func _transition_setup(chr : Character) -> void:
		chr.velocity = Vector3.ZERO

	static func _physics_process(chr : Character, delta : float) -> void:
		if chr.control_direction.x == 0 and chr.control_direction.z == 0:
			chr.animation_player.play("Rest")
		else:
			chr.animation_player.play("Walk")
			chr.velocity = chr.move_and_slide(chr.control_direction * chr.walk_speed, Vector3.UP)
		var scalar_control_direction := chr.scalar_direction(chr.control_direction)
		if scalar_control_direction != 0:
				chr.sprite_3d.flip_h = scalar_control_direction < 0
	
	static func _run(chr : Character, dir : int) -> void:
		match dir:
			LEFT_DIR:
				chr.velocity = Vector3.LEFT.rotated(Vector3.UP, chr.input_angle)
			RIGHT_DIR:
				chr.velocity = Vector3.RIGHT.rotated(Vector3.UP, chr.input_angle)
			UP_DIR:
				chr.velocity = Vector3.FORWARD.rotated(Vector3.UP, chr.input_angle)
			DOWN_DIR:
				chr.velocity = Vector3.BACK.rotated(Vector3.UP, chr.input_angle)
		chr.transition(RunState)

class RunState extends BaseState:
	
	static func _transition_setup(chr : Character) -> void:
		chr.animation_player.play("Run")
		set_sprite_direction(chr)
		
	static func _physics_process(chr : Character, delta : float) -> void:
		if chr.classic_mode:
			chr.velocity = chr.velocity.project(Vector3.RIGHT.rotated(Vector3.UP, chr.input_angle)).normalized()
			chr.velocity = chr.move_and_slide((chr.velocity + 0.99 * chr.control_direction).normalized() * chr.run_speed, Vector3.UP)
		else:
			chr.velocity = chr.move_and_slide((chr.velocity + chr.run_curve * chr.control_direction).normalized() * chr.run_speed, Vector3.UP)
			set_sprite_direction(chr)
			
	static func _move(chr : Character, dir : int) -> void:
		var local_angle := Vector2(chr.velocity.x, chr.velocity.z).angle() - chr.input_angle + (2 * PI)
		if ((dir == LEFT_DIR and (local_angle < 0.25 * PI or local_angle > 1.75 * PI))
					or (dir == UP_DIR and (local_angle > 0.25 * PI and local_angle < 0.75 * PI))
					or (dir == RIGHT_DIR and (local_angle > 0.75 * PI and local_angle < 1.25 * PI))
					or (dir == DOWN_DIR and (local_angle > 1.25 * PI and local_angle < 1.75 * PI))):
						chr.transition(WalkState)
		
	static func set_sprite_direction(chr : Character) -> void:
		var scalar_velocity_direction := chr.scalar_direction(chr.velocity)
		if scalar_velocity_direction != 0:
			chr.sprite_3d.flip_h = scalar_velocity_direction < 0