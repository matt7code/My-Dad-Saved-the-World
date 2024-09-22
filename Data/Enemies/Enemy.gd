extends CharacterBody3D
class_name Enemy

const GRAVITY_STRENGTH = 9.8

@export var blood_effect: PackedScene = preload("res://Effects/GreenBlood.tscn")
@export var attack_speed = 1.0 # (float, 0.1, 5.0, 0.1)
@export var speech_speed = 0.25 # (float, 0.1, 1.0, 0.05)
@export var health := 15.0 # (float, 1, 100, 1)
@export var default_speed := 2.0 # (float, 1, 100, 1)
@export var current_speed := 2.0 # (float, 1, 100, 1)
@export var damage := 5.0 # (float, 1, 100, 1)
@export var defense := 5.0 # (float, 1, 100, 1)
@export var visual_range := 8.0 # (float, 1, 20, 1)
@export var auditory_range := 8.0 # (float, 1, 20, 1)
@export var decay_time:= 60.0 # (float, 1, 60, 1)

var air_time := 0.0
var path = []
var current_node = 0
var direction := Vector3.ZERO
var target := Node.new()
var heard := Vector3.ZERO
var can_attack := true
var patrol_route := []
var patrol_node := 0

@onready var drop_item = preload("res://Items/Potion_Slime.tscn")
@onready var nav : Navigation = $"../Map/Navigation"
@onready var search_timer = $SearchTimer
@onready var speech_timer = $SpeechTimer
@onready var attack_ray = $Body/Torso/Attack
@onready var death_sound = $DeathSound
@onready var death_timer = $DeathTimer
@onready var nav_timer = $NavTimer
@onready var attack_timer = $AttackTimer
@onready var attack_sound = $AttackSound
@onready var anim = $Body/Animate
@onready var torso = $Body/Torso
@onready var head = $Body/Head
@onready var visual = $Detect_Visual/CollisionShape3D: set = set_visual_range
@onready var auditory = $Detect_Sound/CollisionShape3D: set = set_auditory_range
@onready var placard = $Text3D

enum STATE {DEAD, IDLE, PATROL, SEARCHING, CHASING, ATTACKING, EVADE, COVER, FLEEING, THREATENING, WORKING, SPYING}
@export var current_state: STATE = STATE.PATROL


func _ready() -> void:
	set_decay_time(decay_time)
	set_visual_range(visual_range)
	set_auditory_range(auditory_range)
	set_patrol_routes()


func set_patrol_routes():
	var map_waypoints = get_node("../Map/Waypoints").get_children()
	if map_waypoints.is_empty():
		print("No Map Waypoints Found.")
	else:
		var my_old_name = name
		var my_name := ""
		for c in my_old_name:
			if !c.is_valid_int():
				my_name = my_name + str(c)
#		print(name, "'s new name: ", my_name)
		for wp in map_waypoints:
			var wp_name = wp.name as String
			if wp_name.find(my_name) != -1:
				patrol_route.push_back(wp)
		if patrol_route.is_empty():
			print("\t%s's patrol route is empty." % name)
		else:
			print("\t%s's patrol route has %d nodes." % [name, patrol_route.size()])


func set_decay_time(new_val):
	death_timer.wait_time = new_val


func set_auditory_range(new_val):
	auditory.shape.radius = new_val


func set_visual_range(new_val):
	visual.shape.radius = new_val


func _physics_process(delta: float) -> void:
	match current_state:
		STATE.DEAD:
			direction = Vector3.ZERO
			pass
		STATE.IDLE:
			idle()
		STATE.PATROL:
			patrol()
		STATE.SEARCHING:
			searching()
		STATE.CHASING:
			chasing()
		STATE.EVADE:
			pass
		STATE.COVER:
			pass
		STATE.FLEEING:
			pass
		STATE.THREATENING:
			pass
		STATE.WORKING:
			pass
		STATE.SPYING:
			pass
	# Gravity
	if !is_on_floor():
		air_time += delta
		direction.y -= GRAVITY_STRENGTH * air_time
		direction.y = clamp(direction.y, -90, 90)
	else:
		direction.y = 0
		air_time = 0
	if direction != Vector3.ZERO:
		set_velocity(direction.normalized() * current_speed)
		set_up_direction(Vector3.UP)
		move_and_slide()
		direction = velocity
		set_facing()

func searching():
	current_speed = default_speed / 3.0
	if search_timer.is_stopped():
		search_timer.start(5)


func idle():
	anim.play("idle")
	direction = Vector3.ZERO


func set_facing():
	look_at(direction + global_transform.origin, Vector3.UP)
	rotation_degrees.x = 0


func chasing():
	current_speed = default_speed * 3
	if !target:
		current_state = STATE.PATROL
	else:
		if nav_timer.is_stopped() or path.is_empty():
			path = nav.get_simple_path(global_transform.origin, target.global_transform.origin)
			nav_timer.start(0.5)
		if current_node > path.size() - 1:
			current_node = 0
		else:
			direction = path[current_node] - global_transform.origin
			if direction.length() < .5:
				current_node += 1
		attack()


func patrol():
	anim.play("walking")
	current_speed = default_speed
	if patrol_route.is_empty():
		current_state = STATE.IDLE
	else:
		var goal = patrol_route[patrol_node].global_transform.origin
		if global_transform.origin.distance_to(goal) < 0.5:
			if patrol_route.size() == 1: # It's a post
				direction = Vector3.ZERO
				var post_rotation = patrol_route[patrol_node].rotation_degrees.y
				var old_rotation = rotation_degrees.y
				rotation_degrees.y = post_rotation
				print("\t%s (rotation: %f) reached his post (rotation: %f). New Rotation: %f"
						% [name, old_rotation, post_rotation, rotation_degrees.y])
				current_state = STATE.IDLE
			else:
				patrol_node += 1
				if (patrol_node > patrol_route.size() - 1):
					patrol_node = 0
				print("\t%s incrementing node index to %d." % [name, patrol_node])
		else:
			direction = goal - global_transform.origin


#func find_direction(destination) -> Vector3:
##	direction = Vector3.ZERO
#	if path.empty():
##		print("new_path")
#		path = nav.get_simple_path(global_transform.origin, destination)
#		if !path: # Path failed, simple straight line movement
#			direction = global_transform.origin - destination
#	else:
##		print("old_path: ", current_node, "/", path.size())
#		if current_node < path.size() - 1:
#			direction = global_transform.origin - path[current_node]
#		if direction.length() < .1:
#			current_node += 1
#	return direction


func attack():
	if attack_ray.is_colliding():
		var target_body = attack_ray.get_collider()
		if can_attack:
			if target_body.has_method("recieve_damage"):
				speak("Die Human!")
				target_body.recieve_damage(damage)
				if(target_body.health <= 0):
					speak("Looks like meat's back on the menu!")
				else:
					if attack_sound:
						attack_sound.play()
					attack_timer.start(attack_speed)
					can_attack = false


func recieve_damage(dam: int):
	var new_blood = blood_effect.instantiate()
	new_blood.emitting = true
	torso.add_child(new_blood)
	if current_state != STATE.DEAD:
		health -= dam;
		if health <= 0:
			health = 0
			current_state = STATE.DEAD
			death_sound.play()
			var new_drop_item = drop_item.instantiate()
			new_drop_item.global_transform = global_transform
			new_drop_item.translate(Vector3(0, 1, 0))
			Global.drop_node.add_child(new_drop_item)
			death_timer.start()
			visual.disabled = true
			auditory.disabled = true
			speak("Oh nooo!")
			anim.play("Die")
			await anim.animation_finished


func _on_DeathTimer_timeout() -> void:
	anim.play("RotAway")
	await anim.animation_finished
	queue_free()


func _on_AttackTimer_timeout() -> void:
	if current_state != STATE.DEAD:
		can_attack = true


func _on_Detect_Visual_body_entered(body: Node) -> void:
	if current_state != STATE.DEAD:
		print("vision_enter: ", body, body.name)
		if body.name == "Player":
			speak("I've got you now!")
			target = body
			current_state = STATE.CHASING
		elif body.is_in_group("Cats"):
			speak("Damn these flying cats!")
			recieve_damage(1)
			current_state = STATE.EVADE


func _on_Detect_Visual_body_exited(body: Node) -> void:
	if current_state != STATE.DEAD:
		print("vision_exit: ", body, body.name)
		if body == target:
			if target.health > 0:
				speak("Where'd you go?")
			target = null
			current_state = STATE.SEARCHING


func _on_Detect_Sound_body_entered(body: Node) -> void:
	if current_state != STATE.DEAD:
		speak("I hear something!")
		print("sound_enter: ", body, body.name)
		heard = body.global_transform.origin
		current_state = STATE.SEARCHING


func _on_Detect_Sound_body_exited(body: Node) -> void:
	if current_state != STATE.DEAD:
		print("sound_exit: ", body, body.name)
		heard = Vector3.ZERO
#		current_state = STATE.PATROL


func speak(new_val):
	placard.say(new_val)
	speech_timer.start(speech_speed * new_val.length())


func _on_SpeechTimer_timeout() -> void:
	placard.say("")


func _on_SearchTimer_timeout() -> void:
	print("Search_timer_time_out")
	if current_state == STATE.SEARCHING:
		if Global.player.health > 0:
			speak("I guess it was nothing.")
		current_state = STATE.PATROL
