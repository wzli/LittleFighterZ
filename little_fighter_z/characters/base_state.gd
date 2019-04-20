extends Node
class_name BaseState

onready var chr : Character = get_parent()

func _process_state(delta : float) -> void:
	pass
	
func _physics_process_state(delta : float) -> void:
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