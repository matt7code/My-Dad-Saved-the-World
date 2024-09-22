extends Sprite3D

func _ready() -> void:
	$SubViewport.size = $SubViewport/Label.size

func say(new_val):
	$SubViewport/Label.text = new_val
	$SubViewport.size = $SubViewport/Label.size
