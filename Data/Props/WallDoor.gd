extends StaticBody3D

@export var open = false
@onready var anim = $Door/AnimationPlayer

func on_use(_body = null) -> void:
	if open:
		anim.play("Close")
		open = false
	else:
		anim.play("Open")
		open = true
