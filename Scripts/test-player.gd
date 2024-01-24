extends KinematicBody

var velocity = Vector3.ZERO
var current_vel = Vector3.ZERO
var dir = Vector3.ZERO
var snap = Vector3.ZERO

export var SPEED = 10
export var SPRINT_SPEED = 15
export var ACCEL = 60.0

export var GRAVITY = -40.0
export var JUMP_SPEED = 15
var jump_counter = 0
const AIR_ACCEL = 60.0
export var jump_power = 1

export var MOUSE_SENSITIVITY = 0.1

export(NodePath) var camera_path
onready var camera = get_node(camera_path)

#GUNS
onready var AK47 = $eyes/Camera/AK47
onready var AK_anim = $eyes/Camera/AK47/AnimationPlayer

onready var crosshair = $UI/crosshair
onready var crosshair_hit = $UI/crosshair_hit

onready var aim_ray = $eyes/Camera/AimRay
onready var player = $AudioStreamPlayer3D

func _ready():
	# TODO: perfect the audio player later
	player.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _physics_process(delta):
	dir = Vector3.ZERO
	transform = transform.orthonormalized()
	
	if Input.is_action_pressed("forward"):
		dir += transform.basis.z
	elif Input.is_action_pressed("backward"):
		dir -= transform.basis.z
	if Input.is_action_pressed("right"):
		dir -= transform.basis.x
	elif Input.is_action_pressed("left"):
		dir += transform.basis.x
	
	
	dir = dir.normalized()

	if is_on_floor():
		jump_counter = 0
		velocity.y = -0.01
		
	else:
		velocity.y += GRAVITY * delta

		current_vel = Vector3.ZERO

	if Input.is_action_just_pressed("jump") and jump_counter < jump_power:
		jump_counter += 1
		velocity.y = JUMP_SPEED
		snap = Vector3.ZERO
	else:
		snap = Vector3.DOWN

	var speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED
	var target_vel = dir * speed
	
	var accel = ACCEL if is_on_floor() else AIR_ACCEL
	current_vel = current_vel.linear_interpolate(target_vel, accel * delta)
	
	velocity.x = current_vel.x
	velocity.z = current_vel.z
	
	if Input.is_action_pressed("shoot"):
		_shoot_auto(true)
	else:
		_shoot_auto(false)
	
	move_and_slide_with_snap(velocity, snap, Vector3.UP, true, 4, deg2rad(45))
	
func _input(event):
	if event is InputEventMouseMotion:
		$eyes/Camera.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * 1))
		$eyes/Camera.rotation_degrees.x = clamp($eyes/Camera.rotation_degrees.x, -75, 75)
		
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

func _shoot_auto(shot : bool):
	if !AK_anim.is_playing():
		AK_anim.play("shoot")
		if aim_ray.is_colliding():
			# TODO: make enemies, add them to group enemy (collision mask 2)
			# TODO: check if hit() is a already made function or not
			if aim_ray.get_collider().is_in_group("enemy"):
				aim_ray.get_collider().hit()
		
	if shot == false:
		if AK_anim.is_playing():
			AK_anim.play("reset")



