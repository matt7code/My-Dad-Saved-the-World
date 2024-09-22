extends Node3D

@export var color: Color = Color.GREEN


func _ready() -> void:
	var waypoints = get_children()
	for wp in waypoints:
		var arrow = wp.get_node("Arrow")
		var shaft = wp.get_node("Arrow/Shaft")
		var material = arrow.mesh.material.duplicate()
		if !visible:
			arrow.queue_free()
		else:
			material.albedo_color = color
			material.emission_enabled = true
			arrow.material_override = material
			shaft.material_override = material
