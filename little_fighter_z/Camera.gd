extends Camera

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var up := Vector3(0,1,0)
	look_at(Vector3(0,0,0), up)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
