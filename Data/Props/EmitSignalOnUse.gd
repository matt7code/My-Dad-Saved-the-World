extends StaticBody3D

signal on_use

func on_use(body):
	emit_signal("on_use", body)
