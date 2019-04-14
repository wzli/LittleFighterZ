extends Node

export(int) var input_id := 0
export(String) var player_name := "Player0"
	
func _process(delta):
	if not $Character:
		return
	$Character.velocity_request = Vector3.ZERO
	if Input.is_action_pressed(str(input_id) + "_left"):
		$Character.velocity_request.x -= 1
	elif Input.is_action_pressed(str(input_id) + "_right"):
		$Character.velocity_request.x += 1
	if Input.is_action_pressed(str(input_id) + "_up"):
		$Character.velocity_request.z -= 1
	elif Input.is_action_pressed(str(input_id) + "_down"):
		$Character.velocity_request.z += 1
		
func _unhandled_key_input(event):
	if not $Character:
		return
	if event.is_action_pressed(str(input_id) + "_attack"):
		$Character.input_action(Character.Action.ATTACK)
	elif event.is_action_pressed(str(input_id) + "_defend"):
		$Character.input_action(Character.Action.DEFEND)
	elif event.is_action_pressed(str(input_id) + "_jump"):
		$Character.input_action(Character.Action.JUMP)