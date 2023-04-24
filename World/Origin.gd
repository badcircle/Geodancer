extends Node3D
@onready var camera : Camera3D = get_viewport().get_camera_3d()
@export var threshold : float = 1000.0

func shift_origin() -> void:
	# Shift everything by the offset of the camera's position
	global_transform.origin -= camera.global_transform.origin
	print("World shifted to " + str(global_transform.origin))

func _physics_process(delta: float) -> void:
#	# Set the camera to check to be the current camera
#	camera = get_viewport().get_camera_3d()
#	# Check distance of world from camera and shift if greater than threshold
#	if(camera.global_transform.origin.length() > threshold && camera != null):
#		shift_origin()
	pass
