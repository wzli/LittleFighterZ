extends KinematicBody

class_name Character

export var walk_speed: float = 1

enum Action {UP, DOWN, LEFT, RIGHT, ATTACK, DEFEND, JUMP}
enum State {REST, WALK, RUN, PAIN}

var velocity := Vector3()
var velocity_request := Vector3()

func input_action(action : int):
	pass

func _process(delta : float):
	if velocity.x == 0 and velocity.z == 0:
		$AnimationPlayer.play("Rest")
	else:
		if velocity.x < 0:
			$Sprite3D.flip_h = true
		elif velocity.x > 0:
			$Sprite3D.flip_h = false
		$AnimationPlayer.play("Walk")

func _physics_process(delta : float):
	velocity = move_and_slide(velocity_request.normalized() * walk_speed)