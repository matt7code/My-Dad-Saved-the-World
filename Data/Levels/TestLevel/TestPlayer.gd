extends CharacterBody3D

@onready var look_ray = $Head/LookingAt
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var animR = $AnimationPlayerR
@onready var animL = $AnimationPlayerL


@export var CAMERA_ZOOM_SPEED = 1
@export var MOUSE_SENSITIVITY = 0.3
@export var JUMP_STRENGTH_MAX:float = 10
@export var GRAVITY_STRENGTH:float = 9.8
@export var TERMINAL_VELOCITY:float = 90
@export var SPEED_MAX:float = 5

var jump_strength:float = JUMP_STRENGTH_MAX
var speed:float = SPEED_MAX
var direction:= Vector3.ZERO
var velocity:= Vector3.ZERO
var gravity:= Vector3.ZERO
var input:= Vector3.ZERO
var last_input:= Vector3.ZERO
var air_time:float = 0
var camera_zoom:= 4

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.player = self
	arm_self()

func arm_self():
	var club = preload("res://Levels/TestLevel/Club.tscn")
	$ArmJointR/Arm/Hand.add_child(club.instantiate())
	$ArmJointL/Arm/Hand.add_child(club.instantiate())


func action_use():
	animR.play("Using")
	if look_ray.is_colliding():
		var body = look_ray.get_collider()
		print("Looking at: ", body, " \"", body.name, "\"")
		if body.has_method("on_use"):
			body.on_use(self)

func _input(event: InputEvent) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotation_degrees.y -= event.relative.x * MOUSE_SENSITIVITY
			head.rotation_degrees.x -= event.relative.y * MOUSE_SENSITIVITY
			head.rotation_degrees.x = clamp(head.rotation_degrees.x, -90, 90)
	if Input.get_action_strength("ui_restart"):
		var error = get_tree().reload_current_scene()
		if error:
			print("Error: ", error)
	if Input.get_action_strength("ui_fullscreen"):
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (!((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if global_transform.origin.distance_to(camera.global_transform.origin) > 5:
				camera.translate_object_local(Vector3(0,0,-CAMERA_ZOOM_SPEED))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if global_transform.origin.distance_to(camera.global_transform.origin) < 50:
				camera.translate_object_local(Vector3(0,0,CAMERA_ZOOM_SPEED))
		elif event.button_index == MOUSE_BUTTON_LEFT:
			animL.play("WaveArmL")
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			animR.play("WaveArmR")


func _physics_process(delta: float) -> void:
	velocity.z = 0
	velocity.x = 0

	if Input.is_action_pressed("action_use"):
		action_use()

	if is_on_floor():
		speed = SPEED_MAX
		velocity.y = 0
		air_time = 0
		# Input
		input.z = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		input.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		last_input = input
		if Input.is_action_pressed("action_jump"):
			velocity.y = jump_strength
	else:
		input = last_input
		# Gravity
		air_time += delta
		speed = lerp(speed, 0, air_time * delta)
		velocity.y -= GRAVITY_STRENGTH * air_time
		velocity.y = clamp(velocity.y, -90, 90)

	# Direction
	direction = Vector3.ZERO
	direction += transform.basis.z * input.z
	direction += transform.basis.x * input.x
	# Velocity
	velocity += direction.normalized() * speed

	set_velocity(velocity)
	set_up_direction(Vector3.UP)
	move_and_slide()
	velocity = velocity
