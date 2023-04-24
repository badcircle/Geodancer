extends Node3D
var label

# Called when the node enters the scene tree for the first time.
func _ready():
	label = $Label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	label.text = str(Engine.get_frames_per_second())
#	label.text = str($Dynamic/Boat.rotation, $Dynamic/Boat.position, $Dynamic/Base/CharacterArmature.rotation)
	if Input.is_action_pressed("show_sliders"):
		$Build.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
	if Input.is_action_just_released("show_sliders"):
		$Build.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
