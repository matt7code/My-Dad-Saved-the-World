extends CharacterBody3D

var actions
@export var health:= 100

func _ready() -> void:
	var action_node = get_node("Actions")
	if action_node:
		actions = action_node.get_children()

#		var action_list = ""
#		for act in actions:
#			action_list += act.name
#			action_list += " "

#		print("NPC: ", self.name, " I have ", actions.size(), " actions: ", action_list)

func _on_Area_body_entered(body: Node) -> void:
	for act in actions:
		if act.has_method("_on_Area_body_entered"):
			act._on_Area_body_entered(body)


func _on_Area_body_exited(body: Node) -> void:
	for act in actions:
		if act.has_method("_on_Area_body_exited"):
			act._on_Area_body_exited(body)
