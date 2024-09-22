extends AudioStreamPlayer

func _ready():
	var err = Global.connect("sound_mute", Callable(self, "toggle_sound"))
	if err:
		print("Error connecting signal in %s." % name)


func toggle_sound(setting):
	if setting:
		play()
	else:
		stop()
