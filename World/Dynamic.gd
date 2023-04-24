extends Node3D
@export var threshold : float = 150.0

func shift_origin() -> void:
	# Shift everything by the offset of the camera's position
	global_transform.origin.x += $Base.position.x
	global_transform.origin.z += $Base.position.z
	$Base.global_transform.origin.x = global_transform.origin.x
	$Base.global_transform.origin.z = global_transform.origin.z
	print("World shifted to " + str(global_transform.origin))

func _physics_process(delta: float) -> void:
#	if(abs($Base.position.x) > threshold || abs($Base.position.z) > threshold):
#		shift_origin()
#	if Input.is_action_just_pressed("FireSpell"):
#		shift_origin()
#		print($Base.position)
#	pass
