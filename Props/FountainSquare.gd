extends StaticBody3D

@onready var sound = $Sound

func _ready() -> void:
	var err = Global.connect("sound_mute", Callable(self, "toggle_sound"))
	if err:
		print("Error connecting signal in %s." % name)


func toggle_sound(playing):
	if playing:
		sound.play()
	else:
		sound.stop()
