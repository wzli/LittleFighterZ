extends Node

export(int) var input_id := 0
export(PackedScene) var character_scene := preload("res://characters/character.tscn")

var character : Character

func _ready(): 
	character = character_scene.instance() as Character
	add_child(character)

func set_character(new_character_scene : PackedScene):
	character.queue_free()
	character_scene = new_character_scene
	character = character_scene.instance() as Character
	add_child(character)
		
func _process(delta):
	character.velocity_request = Vector3.ZERO
	if Input.is_action_pressed(str(input_id) + "_left"):
		character.velocity_request.x -= 1
	elif Input.is_action_pressed(str(input_id) + "_right"):
		character.velocity_request.x += 1
	if Input.is_action_pressed(str(input_id) + "_up"):
		character.velocity_request.z -= 1
	elif Input.is_action_pressed(str(input_id) + "_down"):
		character.velocity_request.z += 1
		
func _unhandled_key_input(event):
	if event.is_action_pressed(str(input_id) + "_attack"):
		character.input_action(Character.Action.ATTACK)
	elif event.is_action_pressed(str(input_id) + "_defend"):
		character.input_action(Character.Action.DEFEND)
	elif event.is_action_pressed(str(input_id) + "_jump"):
		character.input_action(Character.Action.JUMP)