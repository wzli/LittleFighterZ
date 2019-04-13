extends Spatial

const CHARACTER_PATH := "res://characters/"

export(int) var id : int

var character_node : Character

func _ready():
	reset()
	
func reset(new_id : int = 0, new_name : String = "Player", new_character : String = "bandit"):
	id = new_id
	name = new_name
	var character_scene : Resource = load(
			CHARACTER_PATH + new_character + "/" + new_character + ".tscn")
	assert(character_scene)
	if character_node:
		character_node.queue_free()
	character_node = character_scene.instance()
	add_child(character_node)
	
func _process(delta):
	character_node.velocity_request = Vector3.ZERO
	if Input.is_action_pressed(str(id) + "_left"):
		character_node.velocity_request.x -= 1
	elif Input.is_action_pressed(str(id) + "_right"):
		character_node.velocity_request.x += 1
	if Input.is_action_pressed(str(id) + "_up"):
		character_node.velocity_request.z -= 1
	elif Input.is_action_pressed(str(id) + "_down"):
		character_node.velocity_request.z += 1
		
func _unhandled_key_input(event):
	if event.is_action_pressed(str(id) + "_left"):
		character_node.input_action(Character.Action.LEFT)
	elif event.is_action_pressed(str(id) + "_right"):
		character_node.input_action(Character.Action.LEFT)