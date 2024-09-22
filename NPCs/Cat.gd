extends Node3D

func bye():
	queue_free()

func meow() -> void:
	$Meow.play()
