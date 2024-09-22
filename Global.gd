extends Node3D

var items = {}
var effects = {}

enum STATES {PLAY, PAUSED, INVENTORY}

var STATE = STATES.PLAY

var audio_looping = true
var audio_sound = true

var player
var drop_node

#signal sound_mute(setting)

func _ready() -> void:
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_keybinds()
	load_items()
	load_effects()

func toggle_sound():
	audio_sound = !audio_sound
	if audio_sound:
		print("Sound On")
	else:
		print("Sound Off")
	emit_signal("sound_mute", audio_sound)

func load_effects() -> void:
	effects["Blood"] = preload("res://Effects/Blood.tscn")
	effects["GreenBlood"] = preload("res://Effects/GreenBlood.tscn")

func load_items() -> void:
	items["lantern"] = preload("res://Items/Lantern.tscn")
	items["torch"] = preload("res://Items/Torch.tscn")
	items["sword_iron"] = preload("res://Items/Sword_Iron.tscn")
	items["coin_gold"] = preload("res://Items/Coin_Gold.tscn")
	items["coin_silver"] = preload("res://Items/Coin_Silver.tscn")
	items["coin_copper"] = preload("res://Items/Coin_Copper.tscn")
	items["potion_slime"] = preload("res://Items/Potion_Slime.tscn")
	items["effect_fire"] = preload("res://Items/Effect_Fire.tscn")


func set_keybinds() -> void:
	set_process_input(false)
	var event_key = InputEventKey.new()
	#var event_mouse = InputEventMouseButton.new()

	InputMap.add_action("ui_mute_sound")
	event_key = InputEventKey.new()
	event_key.keycode = KEY_F3
	InputMap.action_add_event("ui_mute_sound", event_key)

	InputMap.add_action("ui_inventory")
	event_key = InputEventKey.new()
	event_key.keycode = KEY_TAB
	InputMap.action_add_event("ui_inventory", event_key)

	InputMap.add_action("ui_fullscreen")
	event_key = InputEventKey.new()
	event_key.keycode = KEY_F11
	InputMap.action_add_event("ui_fullscreen", event_key)

	InputMap.add_action("ui_restart")
	event_key = InputEventKey.new()
	event_key.keycode = KEY_F12
	InputMap.action_add_event("ui_restart", event_key)

	InputMap.add_action("ui_pause")
	event_key = InputEventKey.new()
	event_key.keycode = KEY_ESCAPE
	InputMap.action_add_event("ui_pause", event_key)

	InputMap.add_action("move_up")
	event_key = InputEventKey.new()
	event_key.keycode = KEY_W
	InputMap.action_add_event("move_up", event_key)
	event_key = InputEventKey.new()
	event_key.keycode = KEY_UP
	InputMap.action_add_event("move_up", event_key)

	InputMap.add_action("move_down")
	event_key = InputEventKey.new()
	event_key.keycode = KEY_S
	InputMap.action_add_event("move_down", event_key)
	event_key = InputEventKey.new()
	event_key.keycode = KEY_DOWN
	InputMap.action_add_event("move_down", event_key)

	InputMap.add_action("move_left")
	event_key = InputEventKey.new()
	event_key.keycode = KEY_A
	InputMap.action_add_event("move_left", event_key)
	event_key = InputEventKey.new()
	event_key.keycode = KEY_LEFT
	InputMap.action_add_event("move_left", event_key)

	InputMap.add_action("move_right")
	event_key = InputEventKey.new()
	event_key.keycode = KEY_D
	InputMap.action_add_event("move_right", event_key)
	event_key = InputEventKey.new()
	event_key.keycode = KEY_RIGHT
	InputMap.action_add_event("move_right", event_key)


	InputMap.add_action("action_use")
	event_key = InputEventKey.new()
	event_key.keycode = KEY_E
	InputMap.action_add_event("action_use", event_key)

	InputMap.add_action("action_sprint")
	event_key = InputEventKey.new()
	event_key.keycode = KEY_SHIFT
	InputMap.action_add_event("action_sprint", event_key)

	InputMap.add_action("action_jump")
	event_key = InputEventKey.new()
	event_key.keycode = KEY_SPACE
	InputMap.action_add_event("action_jump", event_key)

	set_process_input(true)
