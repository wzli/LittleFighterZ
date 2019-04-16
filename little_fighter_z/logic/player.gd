extends Node

export(int) var input_id := 0
export(PackedScene) var character_scene := preload("res://characters/character.tscn")
export(bool) var print_combo := false

onready var character := character_scene.instance() as Character
onready var combo_timer := $ComboTimer as Timer

var combo_code : int = Character.ComboKey.NONE

func _ready(): 
	add_child(character)

func _physics_process(delta : float):
	character.velocity_request = Vector3.ZERO
	if Input.is_action_pressed(str(input_id) + "_left"):
		character.velocity_request.x -= 1
	elif Input.is_action_pressed(str(input_id) + "_right"):
		character.velocity_request.x += 1
	if Input.is_action_pressed(str(input_id) + "_up"):
		character.velocity_request.z -= 1
	elif Input.is_action_pressed(str(input_id) + "_down"):
		character.velocity_request.z += 1

func _unhandled_key_input(event : InputEventKey):
	if combo_timer.wait_time - combo_timer.time_left < 0.05:
		combo_code = Character.ComboKey.NONE
	if not add_combo_key():
	    return
	combo_timer.start()
	combo_code = combo_code & 0x1FF
	character.input_combo(combo_code)
	if print_combo:
		print("%d %s: %s" % [input_id, name, combo_string(combo_code)])
	combo_code = (combo_code << 3)

func _on_ComboTimer_timeout():
	combo_code = Character.ComboKey.NONE

func set_character(new_character_scene : PackedScene) -> bool:
	var new_character := new_character_scene.instance() as Character
	if not new_character:
		return false
	character.queue_free()
	character = new_character
	character_scene = new_character_scene
	add_child(character)
	return true

func add_combo_key() -> bool:
	if Input.is_action_pressed(str(input_id) + "_attack"):
		combo_code += Character.ComboKey.ATTACK
	elif Input.is_action_pressed(str(input_id) + "_defend"):
		combo_code += Character.ComboKey.DEFEND
	elif Input.is_action_pressed(str(input_id) + "_jump"):
		combo_code += Character.ComboKey.JUMP
	elif Input.is_action_pressed(str(input_id) + "_up"):
		combo_code += Character.ComboKey.UP
	elif Input.is_action_pressed(str(input_id) + "_down"):
		combo_code += Character.ComboKey.DOWN
	elif Input.is_action_pressed(str(input_id) + "_left"):
		combo_code += Character.ComboKey.LEFT
	elif Input.is_action_pressed(str(input_id) + "_right"):
		combo_code += Character.ComboKey.RIGHT
	else:
	    return false
	return true

func combo_string(combo_code : int) -> String:
	var combo_string := "???"
	for i in range(3):
		match combo_code & 0x7:
			Character.ComboKey.NONE:
				combo_string[i] = '_'
			Character.ComboKey.UP:
				combo_string[i] = '^'
			Character.ComboKey.DOWN:
				combo_string[i] = 'v'
			Character.ComboKey.LEFT:
				combo_string[i] = '<'
			Character.ComboKey.RIGHT:
				combo_string[i] = '>'
			Character.ComboKey.Attack:
				combo_string[i] = 'A'
			Character.ComboKey.DEFEND:
				combo_string[i] = 'D'
			Character.ComboKey.JUMP:
				combo_string[i] = 'J'
		combo_code = combo_code >> 3
	return combo_string