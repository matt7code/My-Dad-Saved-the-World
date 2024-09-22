extends StaticBody3D

signal on_body

func used(body):
	emit_signal("on_body", on_body)
