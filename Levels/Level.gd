extends Node3D

@export var environment = preload("res://Environments/Forest_Day.tscn")
#
func _ready() -> void:
	if environment:
		add_child(environment.instantiate())
