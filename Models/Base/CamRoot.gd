extends Node3D

var camrot_h = 0.0
var h_sens = 0.1
var h_accel = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
#	$h/v/SpringArm/Camera3D.add_exception(get_parent())

func _input(event):
	if event is InputEventMouseMotion:
		camrot_h += -event.relative.x * h_sens

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$h.rotation_degrees.y = lerp($h.rotation_degrees.y, camrot_h, delta * h_accel)
