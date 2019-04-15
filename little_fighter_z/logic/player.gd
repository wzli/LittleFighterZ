extends Node

export(int) var input_id := 0
export(PackedScene) var character_scene := preload("res://characters/character.tscn")

onready var character := character_scene.instance() as Character
onready var combo_timer := $ComboTimer as Timer

var combo_code : int = Character.ComboKey.NONE

func _ready(): 
	add_child(character)

func set_character(new_character_scene : PackedScene):
	character.queue_free()
	character_scene = new_character_scene
	character = character_scene.instance() as Character
	add_child(character)
		
func _process(delta : float):
	character.velocity_request = Vector3.ZERO
	if Input.is_action_pressed(str(input_id) + "_left"):
		character.velocity_request.x -= 1
	elif Input.is_action_pressed(str(input_id) + "_right"):
		character.velocity_request.x += 1
	if Input.is_action_pressed(str(input_id) + "_up"):
		character.velocity_request.z -= 1
	elif Input.is_action_pressed(str(input_id) + "_down"):
		character.velocity_request.z += 1
		
func add_combo_key():
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
	
func _unhandled_key_input(event : InputEventKey):
	if combo_timer.wait_time - combo_timer.time_left < 0.05:
		combo_timer.start()
		return
	if not add_combo_key():
	    return
	combo_timer.start()
	combo_code = combo_code & 0x1FF
	character.input_combo(combo_code)
	combo_code = (combo_code << 3)

func _on_ComboTimer_timeout():
	combo_code = Character.ComboKey.NONE