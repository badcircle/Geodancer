extends CharacterBody3D

const SPEED = 13.0
const MINCOORD = -9999
const MAXCOORD = 9999
const TWO_PI = PI * 2

var move_speed = SPEED
var walk_speed = SPEED * 0.5
var run_speed = SPEED * 2
var acceleration = 6.0
var angular_acceleration = 7.0
var boat_angular_acceleration = 2.0
var falling = false
var landed = true
var scaleGoal : float = 1
var temp : float
var materia : float
var emission : float

var direction = Vector3.ZERO
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum STATE {ONFOOT, BOAT}
@export var player_state : STATE
var dragging = false
var dragged_item = false
var being_placed = false

signal vehicle_exited()

@onready var ani = $AnimationTree
@onready var ca = $CharacterArmature
@onready var body = $CharacterArmature/Skeleton3D/Body
@onready var slider = %HSlider

@onready var camera : Camera3D = get_viewport().get_camera_3d()

@export_range(0, 1) var charge_amt : float = 0
@export var coldColor : Color
@export var hotColor : Color

func _ready():
	velocity = Vector3.ZERO
	temp = 0.5
	materia = 0.5
	player_state = STATE.ONFOOT

func _physics_process(delta):
	match player_state:
		STATE.ONFOOT:
			jump_and_gravity(delta)
			dir_and_vel(delta)
			move_and_blend(direction, delta)
			emission = charge_materia(delta)
			climb(delta)
			check_drag()
			move_and_slide()
			if Input.is_action_just_pressed("enter_vehicle") and not dragging:
				enter_vehicle()
		STATE.BOAT:
			jump_and_gravity(delta)
			dir_and_vel(delta)
			move_and_blend(direction, delta)
			move_and_slide()
	
	position.x = clamp(position.x, MINCOORD, MAXCOORD)
	position.z = clamp(position.z, MINCOORD, MAXCOORD)

func move_and_blend(dir, delta):
	var blend_speed = 0
	var timescale = 1
	# slope is defined as 75% at 3x scale and 100% at 1, so (0.750 - 1) / (3 - 1) = -0.25
	var slope = -0.25
	# yIntercept is 0.750 - slope * 1 = 0.875
	var yIntercept = 1
	if scale.x > 1:
		timescale =  0.25 + (slope * scale.x + yIntercept)
	else:
		timescale = 1
	if dir:
		blend_speed = (abs(velocity.x) + abs(velocity.z)) / move_speed
		blend_speed = clamp(blend_speed, 0, 1)
		if player_state == STATE.BOAT || dragging:
			ca.rotation.y = lerp_angle(ca.rotation.y, atan2(dir.x, dir.z), delta * boat_angular_acceleration)
		else:
			ca.rotation.y = lerp_angle(ca.rotation.y, atan2(dir.x, dir.z), delta * angular_acceleration)
		if ca.rotation.y > TWO_PI:
			ca.rotation.y -= TWO_PI
		if ca.rotation.y < -TWO_PI:
			ca.rotation.y += TWO_PI
	if not is_on_floor():
		blend_speed = clamp(blend_speed, 0, 0.5)
	if player_state == STATE.BOAT:
		blend_speed = 0
	if Input.is_action_pressed("run"):
		ani["parameters/walk-run/blend_amount"] = move_toward(ani["parameters/walk-run/blend_amount"], blend_speed * -1, delta * SPEED)
	else:
		ani["parameters/walk-run/blend_amount"] = move_toward(ani["parameters/walk-run/blend_amount"], blend_speed, delta * SPEED)
	ani["parameters/walk/blend_amount"] = move_toward(ani["parameters/walk/blend_amount"], blend_speed, delta * SPEED)
	ani["parameters/run/blend_amount"] = move_toward(ani["parameters/run/blend_amount"], blend_speed, delta * SPEED)
	ani["parameters/time/scale"] = move_toward(ani["parameters/time/scale"], timescale, delta)
	
	if Input.is_action_pressed("grow"):
		slider.value = scaleGoal
		if !$CharacterArmature/Caster/Grow.is_colliding():
			scaleGoal = 2
	if Input.is_action_pressed("shrink"):
		scaleGoal = 1
		slider.value = scaleGoal
	if $CharacterArmature/Caster/Grow.is_colliding():
		scaleGoal = 1
		slider.value = scaleGoal
	scale = lerp(scale, Vector3(scaleGoal, scaleGoal, scaleGoal), delta)
	$CharacterArmature/Skeleton3D/Body.get_surface_override_material(0).emission = coldColor.lerp(hotColor, temp)
	$CharacterArmature/Skeleton3D/Body.get_surface_override_material(0).albedo_color.a = materia
	
func charge_materia(delta):
	if Input.is_action_pressed("Cast Dice"):
		if charge_amt < .45:
			charge_amt = move_toward(charge_amt, 1, delta / 2)
		else:
			charge_amt = move_toward(charge_amt, 1, delta / 6)
	else:
		charge_amt = move_toward(charge_amt, 0.01675, delta * 8)
	var amount = charge_amt * 18
	$CharacterArmature/Skeleton3D/Body.get_surface_override_material(0).emission_energy_multiplier = amount
	return amount

func jump_and_gravity(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		falling = true
		ani["parameters/float/blend_amount"] = move_toward(ani["parameters/float/blend_amount"], 0.5, delta)
	else:
		ani["parameters/float/blend_amount"] = move_toward(ani["parameters/float/blend_amount"], 0, delta)
		falling = false
		if !landed:
			if !Input.is_action_pressed("jump"):
				landed = true
			else:
				landed = false
		
	if Input.is_action_just_pressed("jump") and landed and player_state == STATE.ONFOOT and not dragging:
		velocity.y = gravity * 0.25
		landed = false
	if Input.is_action_pressed("jump") and landed and player_state == STATE.ONFOOT:
		ani["parameters/float/blend_amount"] = move_toward(ani["parameters/float/blend_amount"], 0.5, delta)
	if Input.is_action_pressed("jump") and !is_on_floor():
		ani["parameters/float/blend_amount"] = move_toward(ani["parameters/float/blend_amount"], 1, delta * gravity)
		if $CharacterArmature/Caster/Ray.is_colliding():
			velocity.y += (gravity * delta) * 1.618
#		rotate_neck(delta)

func dir_and_vel(delta):
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir:
		var h_rot = $CamRoot/h.global_transform.basis.get_euler().y
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).rotated(Vector3.UP, h_rot).normalized()
		if Input.is_action_pressed("run") and not dragging:
			move_speed = run_speed
		else:
			move_speed = SPEED
		if player_state == STATE.BOAT:
			move_speed = 0.1
		velocity.x = lerp(velocity.x, direction.x * move_speed, delta * acceleration)
		velocity.z = lerp(velocity.z, direction.z * move_speed, delta * acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)
	if player_state == STATE.BOAT:
		position = get_parent().get_node("Boat").position
#
	if not is_on_floor():
		velocity.x = velocity.x * .9
		velocity.z = velocity.z * .9
		
func climb(delta):
	if $CharacterArmature/Caster/Climb.is_colliding():
		var stairHeight = $CharacterArmature/Caster/Climb.get_collision_point()
#		print(abs(stairHeight.y) - abs(position.y))
		if position.y < stairHeight.y and abs(stairHeight.y) - abs(position.y) < 1:
			position = lerp(position, stairHeight, delta * 16)

func drag():
	if Input.is_action_just_pressed("drag") and dragging:
		being_placed = place_item(dragged_item)
		if being_placed:
			place_item(being_placed)
		dragging = false
		dragged_item = false
		return false
	if Input.is_action_just_pressed("drag") and is_on_floor():
		dragged_item = get_parent().get_node("Boat")
		dragging = true
		return dragged_item
	return false

func being_dragged(item):
	var delta = get_process_delta_time()
	item.position = position + Vector3(0,12,0)
	item.rotation = ca.rotation
	item.rotation.z = lerp(item.rotation.z, randf_range(-PI,PI), delta * 0.15)

func check_drag():
	var drag_check = drag()
	if dragged_item:
		dragging = true
	if dragging:
		being_dragged(dragged_item)

func place_item(item):
	if $CharacterArmature/Placer.is_colliding():
		var target = $CharacterArmature/Placer.get_collision_point()
		item.position = target
		item.rotation.x = 0
		item.rotation.z = 0
		return item
	else:
		return false
		
func _on_h_slider_value_changed(value):
	if !$CharacterArmature/Caster/Grow.is_colliding():
		scaleGoal = value
	else:
		slider.value = scaleGoal

func _on_h_slider_2_value_changed(value):
	temp = value
	
func _on_h_slider_3_value_changed(value):
	materia = value

func enter_vehicle():
	var boat = get_parent().get_node("Boat")
	position = boat.position + Vector3(0,3,0)
	ca.rotation = Vector3.ZERO
	ani["parameters/walk-run/blend_amount"] = 0
	ani["parameters/float/blend_amount"] = 0
	boat.emit_signal("vehicle_entered")
	player_state = STATE.BOAT

func _on_vehicle_exited():
	player_state = STATE.ONFOOT
