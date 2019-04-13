extends KinematicBody

export var walk_speed: float = 1
var velocity = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Rest")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.x = 0
	velocity.y = 0
	velocity.z = 0
	
	if Input.is_action_pressed("ui_right"):
		velocity.x = walk_speed
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -walk_speed
		
	if Input.is_action_pressed("ui_up"):
		velocity.z = -walk_speed
	elif Input.is_action_pressed("ui_down"):
		velocity.z = walk_speed
	
	if velocity.x == 0 and velocity.z == 0:
		$AnimationPlayer.play("Rest")
	else:
		$AnimationPlayer.play("Walk")
	$Sprite3D.flip_h = velocity.x < 0
	velocity = move_and_slide(velocity)