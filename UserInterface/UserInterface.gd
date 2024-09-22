extends CanvasLayer

var inventory := false
var player:Node = null
@onready var menu = $Menu

func _ready() -> void:
	menu.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_inventory"):
		if Global.STATE == Global.STATES.PLAY:
			Global.STATE = Global.STATES.INVENTORY
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			menu.visible = true
		elif Global.STATE == Global.STATES.INVENTORY:

			Global.STATE = Global.STATES.PLAY
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			menu.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_mute_sound"):
		Global.toggle_sound()

	if Input.is_action_just_pressed("ui_restart"):
		restart()

	if Input.is_action_just_pressed("ui_fullscreen"):
		OS.set_deferred("window_fullscreen", !((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN)))
		print("Fullscreen Toggled")

	if Input.is_action_just_pressed("ui_pause"):
		if Global.STATE == Global.STATES.PLAY:
			Global.STATE = Global.STATES.PAUSED
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			print("Game Menu Open")

		elif Global.STATE == Global.STATES.PAUSED:
			Global.STATE = Global.STATES.PLAY
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().paused = false
			print("Game Menu Closed")

	# Catch falling players
	if player and player.transform.origin.y < -100:
		restart()
	else:
		player = Global.player
		if !player:
			print("Canvas cannot access player.")
			pass


func restart() -> void:
	Global.drop_node.queue_free()
	var err = get_tree().reload_current_scene()
	if err:
		print("Error reloading scene:", err)
	else:
		print("Scene reload complete.")
