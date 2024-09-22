extends Node3D

func _on_Area_body_entered(body: Node) -> void:
	if $Greeting != null:
		if body.is_in_group("Player"):
				$Greeting.play()
