extends Node

var heal_timer
var healing:= false
@onready var healer = get_node("../../")
var target


func _ready() -> void:
	heal_timer = Timer.new()
	add_child(heal_timer)
	heal_timer.connect("timeout", Callable(self, "_on_timeout"))


func _on_Area_body_entered(body) -> void:
	if body.is_in_group("Player"):
		if body != healer:
			healing = true
			target = body
			heal(target)


func heal(body):
	print("Heal from ", healer.name, " to ", body.name, " engaged.")
	body.health += 10
	body.health = clamp(body.health, 0, 100)
	heal_timer.start(1.0)


func _on_timeout():
	if healing:
		heal(target)


func _on_Area_body_exited(body) -> void:
	if body.is_in_group("Player"):
		print("\t", healer.name, ": ", body.name, " is too far away to heal.")
		healing = false
