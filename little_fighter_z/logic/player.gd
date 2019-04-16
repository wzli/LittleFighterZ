extends Node

export(int) var input_id := 0
export(PackedScene) var character_scene := preload("res://characters/character.tscn")
export(bool) var print_combo := false

onready var character := character_scene.instance() as Character
onready var combo_timer := $ComboTimer as Timer

enum ComboKey {NONE, UP, DOWN, LEFT, RIGHT, ATTACK, DEFEND, JUMP}
var combo_code : int = ComboKey.NONE
var combo : String = '___'

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
	var combo_key := parse_combo_key(event)
	var prev_combo_key := combo_code & 0x7
	match combo_key:
		ComboKey.LEFT, ComboKey.RIGHT:
			pass
		ComboKey.NONE, prev_combo_key:
			return
	combo_timer.start()
	combo_code = (combo_code << 3) | combo_key
	parse_combo(combo_code) 
	character.input_combo(combo)
	if print_combo:
		print("%d %s: %s" % [input_id, name, combo])

func _on_ComboTimer_timeout():
	combo_code = ComboKey.NONE

func set_character(new_character_scene : PackedScene) -> bool:
	var new_character := new_character_scene.instance() as Character
	if not new_character:
		return false
	character.queue_free()
	character = new_character
	character_scene = new_character_scene
	add_child(character)
	return true

func parse_combo_key(event : InputEventKey) -> int:
	if event.is_action_pressed(str(input_id) + "_attack"):
		return ComboKey.ATTACK
	elif event.is_action_pressed(str(input_id) + "_defend"):
		return ComboKey.DEFEND
	elif event.is_action_pressed(str(input_id) + "_jump"):
		return ComboKey.JUMP
	elif event.is_action_pressed(str(input_id) + "_up"):
		return ComboKey.UP
	elif event.is_action_pressed(str(input_id) + "_down"):
		return ComboKey.DOWN
	elif event.is_action_pressed(str(input_id) + "_left"):
		return ComboKey.LEFT
	elif event.is_action_pressed(str(input_id) + "_right"):
		return ComboKey.RIGHT
	else:
	    return ComboKey.NONE

func parse_combo(combo_code : int) -> void:
	for i in range(2, -1, -1):
		match combo_code & 0x7:
			ComboKey.UP:
				combo[i] = '^'
			ComboKey.DOWN:
				combo[i] = 'v'
			ComboKey.LEFT:
				combo[i] = '<'
			ComboKey.RIGHT:
				combo[i] = '>'
			ComboKey.ATTACK:
				combo[i] = 'A'
			ComboKey.DEFEND:
				combo[i] = 'D'
			ComboKey.JUMP:
				combo[i] = 'J'
			ComboKey.NONE, _:
				combo[i] = '_'
		combo_code = combo_code >> 3