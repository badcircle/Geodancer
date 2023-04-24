extends RigidBody3D
enum STATE {SLEEP,DRIVING,PARKED}
@export var boat_state : STATE
var cooldown = false
signal vehicle_entered

@export var speed = 200
var current_speed : int

# Called when the node enters the scene tree for the first time.
func _ready():
	boat_state = STATE.SLEEP

func _integrate_forces(state):
	keep_afloat()
	if boat_state == STATE.DRIVING:
		if Input.is_action_pressed("ui_up"):
			apply_central_impulse(global_transform.basis * -Vector3.FORWARD * current_speed)
		if Input.is_action_pressed("ui_down"):
			apply_central_impulse(global_transform.basis * -Vector3.FORWARD * current_speed)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if boat_state == STATE.DRIVING:
		var base = get_parent().get_node("Base")
		if Input.is_action_pressed("run"):
			current_speed = speed * 2.5
		else:
			current_speed = speed
		if position.y > 0:
			current_speed = speed * 0.75
		if position.y > 1:
			current_speed = speed * 0.35
		rotation.y = lerp_angle(rotation.y, base.ca.rotation.y, delta * 2)
		if Input.is_action_pressed("ui_down"):
			rotation.y = lerp_angle(rotation.y, base.ca.rotation.y + PI * 2, delta)
			
		position.x = clamp(position.x, base.MINCOORD, base.MAXCOORD)
		position.z = clamp(position.z, base.MINCOORD, base.MAXCOORD)
		
		if !cooldown:
			if Input.is_action_just_pressed("enter_vehicle"):
				get_parent().get_node("Base").emit_signal("vehicle_exited")
				boat_state = STATE.SLEEP

func keep_afloat():
	if $Floaters/fs.global_transform.origin.y < 0:
		apply_impulse(Vector3.UP*12.75*-$Floaters/fs.global_transform.origin, $Floaters/fs.global_transform.origin-global_transform.origin)
	if $Floaters/fp.global_transform.origin.y < 0:
		apply_impulse(Vector3.UP*12.75*-$Floaters/fp.global_transform.origin, $Floaters/fp.global_transform.origin-global_transform.origin)
	if $Floaters/rs.global_transform.origin.y < 0:
		apply_impulse(Vector3.UP*12.75*-$Floaters/rs.global_transform.origin, $Floaters/rs.global_transform.origin-global_transform.origin)
	if $Floaters/rp.global_transform.origin.y < 0:
		apply_impulse(Vector3.UP*12.75*-$Floaters/rp.global_transform.origin, $Floaters/rp.global_transform.origin-global_transform.origin)


func _on_vehicle_entered():
	boat_state = STATE.DRIVING
	cooldown = true
	$Timer.start()

func _on_timer_timeout():
	cooldown = false
