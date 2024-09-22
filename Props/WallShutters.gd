extends StaticBody3D

@export var open = false
@onready var anim = $AnimationPlayer

func on_use(body = null) -> void:
	if body:
		print("Toggling Shutters, Sir ", body.name)
	if open:
		anim.play("Close")
		open = false
		print("Shutters closed.")
	else:
		anim.play("Open")
		open = true
		print("Shutters opened.")
