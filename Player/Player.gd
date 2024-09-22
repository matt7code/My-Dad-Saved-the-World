extends CharacterBody3D

@export var jump_strength:float = 10
@export var gravity_strength:float = 9.8
@export var terminal_velocity:float = 90
@export var speed:float = 10
@export var MOVE_AIR_MODIFIER:float = 0.1
@export var ZOOM_MIN:float = 2.0
@export var ZOOM_MAX:float = 100.0

@export var health:= 100.0
@export var stamina:= 100.0
@export var armor:= 5
@export var attack:= 2

@export var acceleration:float = 6
@export var RESPAWN_TIME:float = 3.0
@export var CAMERA_ZOOM_SPEED:= 1.0
@export var INPUT_DEAD_ZONE = 0.05
@export var MOUSE_SENSITIVITY:= 0.3
@export var JUMP_STRENGTH_MAX:= 10.0
@export var GRAVITY_STRENGTH:= 9.8
@export var TERMINAL_VELOCITY:= 90.0
@export var SPEED_MAX:= 1.4
@export var SPRINT_BONUS:= 4.0
@export var MIN_WEAPON_POWER_UP_BONUS:= 1.0

@export var STAM_REGEN = 15.0
@export var STAM_COST_POWER_UP_SWING = 8.0
@export var STAM_COST_SPRINT = 7.5
@export var STAM_COST_JUMP = 10.0
@export var STAM_COST_SWING = 8.0

enum ANIM {IDLE, STOP, WALK, JUMP, ATTACK, RAISE_WEAPON}

var cat_counter := -1

var things_near_our_weapon = []
var target:Node = null
var zoom_distance:float = 0.0

var direction:Vector3 = Vector3.ZERO
var movement:Vector3 = Vector3.ZERO
var another_speed:Vector3 = Vector3.ZERO

var input:Vector3 = Vector3.ZERO
var last_input:Vector3
var gravity:Vector3 = Vector3.ZERO
var horizontal_velocity:Vector3 = Vector3.ZERO

var cumulative_delta:float = 0
var air_time:float = 0
var dead := false
var weapon_raised :=false
var attacking := false
var weapon_power_up_bonus := 1.0
var damage = 2
var sprinting := false

@onready var head = $Body/Head
@onready var camera = $Body/Head/Camera3D
@onready var step_sound = $StepSound
@onready var jump_sound = $JumpSound
@onready var looking_at = $Body/Head/Look
@onready var anim = $Body/Animate
@onready var arm_right = $Body/ArmRight
@onready var arm_left = $Body/ArmLeft
@onready var right_hand = $Body/ArmRight/HandRight
@onready var left_hand = $Body/ArmLeft/HandLeft
@onready var left_arm = $Body/ArmLeft
@onready var death_timer = $DeathTimer
@onready var slash_sound = $SlashSound
@onready var torso = $Body/Torso
@onready var life_bar = $Hud/Life
@onready var stam_bar = $Hud/Stamina

@onready var cat = preload("res://NPCs/Cat.tscn")

func _ready() -> void:
	anim.stop()
	Global.player = self
	_hold_left("lantern")
	_hold_right("sword_iron")
#	_hold_right("effect_fire")


func _hold_left(item):
	var held = Global.items[item].instantiate()
	left_hand.add_child(held)
	if held.has_method("on_held"):
		held.on_held()
	_adjust_grip(held)

func _hold_right(item):
	var held = Global.items[item].instantiate()
	right_hand.add_child(held)
	if held.has_method("on_held"):
		held.on_held()
	_adjust_grip(held)

func _adjust_grip(held):
	# Adjust for grip
	var grip = held.get_node("Grip")
	if grip:
#		print("Grip found: ", grip.transform.origin)
		held.translate_object_local(-grip.transform.origin)
	else:
		print("No grip found on held item: ", held.name)
		pass


func _input(event: InputEvent) -> void:
	if !Global.STATE == Global.STATES.PLAY or dead:
		return
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		#Camera Move
		if event is InputEventMouseMotion:
			rotation_degrees.y -= event.relative.x * MOUSE_SENSITIVITY
			head.rotation_degrees.x -= event.relative.y * MOUSE_SENSITIVITY
			head.rotation_degrees.x = clamp(head.rotation_degrees.x, -90, 90)

		#Camera Zoom
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_distance = global_transform.origin.distance_to(camera.global_transform.origin)
				if event.button_index == MOUSE_BUTTON_WHEEL_UP and zoom_distance > ZOOM_MIN:
					camera.translate_object_local(Vector3(0,0,-CAMERA_ZOOM_SPEED))
				elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and zoom_distance < ZOOM_MAX:
					camera.translate_object_local(Vector3(0,0,CAMERA_ZOOM_SPEED))

func _update_bars(delta):
	if sprinting:
		stamina -= STAM_COST_SPRINT * delta
	else:
		stamina += STAM_REGEN * delta

	health = clamp(health, 0, 100)
	stamina = clamp(stamina, 0, 100)
	life_bar.value = health
	stam_bar.value = stamina

	if stamina == 100:
		stam_bar.visible = false
	else:
		stam_bar.visible = true
	if health == 100:
		life_bar.visible = false
	else:
		life_bar.visible = true


func _physics_process(delta: float) -> void:
	if !Global.STATE == Global.STATES.PLAY or dead:
		_anim(ANIM.STOP)
		return
	_vital_physics_and_input(delta)
	_attacking(delta)
	_update_bars(delta)

	if is_on_floor():
		if horizontal_velocity.length() > 0.5:
			_anim(ANIM.WALK)
		else:
			pass
			_anim(ANIM.STOP)
	else:
		pass
#		_anim(ANIM.JUMP)

	if left_hand:
		anim.play("walking_holding")
	if right_hand:
		anim.play("walking_wielding")
	if left_hand and right_hand:
		anim.play("walking_holding_wielding")

	if Input.is_action_just_pressed("action_use"):
		action_use()

func action_use():
	if anim.current_animation != "using":
		anim.play("using")
	var prev_rot = head.rotation_degrees.y
	head.rotation_degrees.y = 0
	if looking_at.is_colliding():
		var body = looking_at.get_collider()
		head.rotation_degrees.y = prev_rot
		print("Looking at: ", body, " \"", body.name, "\"")
		if body.has_method("on_use"):
			body.on_use(self)


func _attacking(delta) -> void:
	if weapon_raised:
		weapon_power_up_bonus += delta
		stamina -= STAM_COST_POWER_UP_SWING * delta
		if stamina == 0:
			weapon_raised = false


	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if stamina > 0:
			_anim(ANIM.RAISE_WEAPON)
			weapon_raised = true

#		print("Weapon Raised: ", weapon_power_up_bonus)
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and weapon_raised:
		weapon_raised = false
		stamina -= STAM_COST_SWING
		if stamina > 0:
			_anim(ANIM.ATTACK)
			slash_sound.play()
			for body in things_near_our_weapon:
				if body.has_method("recieve_damage"):
					print("Attack: ", damage * weapon_power_up_bonus, " (", damage, "*",
							weapon_power_up_bonus, ") to ", body.name, " HP Left: ",
							body.health-damage*weapon_power_up_bonus)
					body.recieve_damage(damage * weapon_power_up_bonus)
				else:
					print("This target cannot be hurt... wow.")
			weapon_power_up_bonus = MIN_WEAPON_POWER_UP_BONUS

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		launch_cat()


func _on_Attack_Area_body_entered(body: Node) -> void:
	things_near_our_weapon.append(body)
	print("Body attack size: ", things_near_our_weapon.size())


func _on_Attack_Area_body_exited(body: Node) -> void:
	things_near_our_weapon.erase(body)
	print("Body attack size: ", things_near_our_weapon.size())


func _anim(act) -> void:
	if dead:
		return
	match act:
		ANIM.IDLE:
			pass
		ANIM.STOP:
			step_sound.stop()
		ANIM.WALK:
			if !step_sound.playing:
				step_sound.play()
		ANIM.JUMP:
			pass
		ANIM.RAISE_WEAPON:
			pass
		ANIM.ATTACK:
			pass

func _done_attacking():
	attacking = false

# Don't let the arms fall in lock step after 'use'
func _anim_use_done() -> void:
		arm_right.seek(arm_left.current_animation_position)

func recieve_damage(get_damage: int):
	var blood = Global.effects["Blood"].instantiate() as CPUParticles3D
	if blood:
		torso.add_child(blood)
		blood.emitting = true
	else:
		print("Failed to load Blood Effect")
	if dead:
		return
	health -= get_damage;
	if health <= 0:
		dead = true
		anim.play("Die")
		await anim.animation_finished
		death_timer.start(RESPAWN_TIME)

func _on_DeathTimer_timeout() -> void:
	if get_parent().has_method("player_died"):
		get_parent().player_died()
	else:
		var err = get_tree().reload_current_scene()
		if err:
			print_debug(err, ": Scene reload failed in Player.gd at line ~210")


func _vital_physics_and_input(delta) -> void:
	velocity.z = 0
	velocity.x = 0

	if is_on_floor():
		speed = SPEED_MAX
		if Input.get_action_strength("action_sprint") > INPUT_DEAD_ZONE:
			if stamina > 0:
				speed += (speed * SPRINT_BONUS)
				if last_input.length() > 0:
					sprinting = true
		else:
			sprinting = false

		velocity.y = 0
		air_time = 0
		# Input
		input.z = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		input.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		horizontal_velocity = input.normalized()
		last_input = input
		if Input.is_action_pressed("action_jump"):
			stamina -= STAM_COST_JUMP
			if stamina > 0:
				velocity.y = jump_strength
	else:
		input = last_input
		# Gravity
		air_time += delta
		speed = lerp(speed, 0.0, air_time * delta)
		velocity.y -= GRAVITY_STRENGTH * air_time
		velocity.y = clamp(velocity.y, -90, 90)

	# Direction
	direction = Vector3.ZERO
	direction += transform.basis.z * horizontal_velocity.z
	direction += transform.basis.x * horizontal_velocity.x
	# Velocity
	velocity += direction.normalized() * speed
	set_velocity(velocity)
	set_up_direction(Vector3.UP)
	move_and_slide()
	velocity = velocity

func launch_cat():
	cat_counter += 1
	if cat_counter % 10 != 0:
		return
	var new_cat = cat.instantiate()
	get_parent().add_child(new_cat)
	new_cat.global_transform.origin = global_transform.origin
	new_cat.translate(Vector3(0, 1.5, 0))
	new_cat.rotation = rotation
	new_cat.rotation_degrees.x += 15


	var cat_timer = Timer.new()
	cat_timer.connect("timeout", Callable(new_cat, "bye"))
	cat_timer.wait_time = 3.0
	cat_timer.autostart = true
	new_cat.add_child(cat_timer)

	# Send it flying!
	new_cat.meow()
	new_cat.linear_velocity = -transform.basis.z * 20
