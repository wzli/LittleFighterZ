extends KinematicBody2D

const WALK_SPEED = 100
var velocity = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Rest")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.x = 0
	velocity.y = 0
	
	if Input.is_action_pressed("ui_right"):
		velocity.x = WALK_SPEED
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -WALK_SPEED
		
	if Input.is_action_pressed("ui_up"):
		velocity.y = -WALK_SPEED
	elif Input.is_action_pressed("ui_down"):
		velocity.y = WALK_SPEED
	
	if velocity.x == 0 and velocity.y == 0:
		$AnimationPlayer.play("Rest")
	else:
		$AnimationPlayer.play("Walk")
	$Sprite.flip_h = velocity.x < 0
	velocity = move_and_slide(velocity)