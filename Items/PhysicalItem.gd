extends RigidBody3D

var activated = true
var item_id

func on_use(_usedby):
	if freeze_mode == RigidBody3D.FREEZE_MODE_STATIC:
		# Static item in the world
		if name == "Torch":
			activated = !activated
			if activated:
				torch_ignite()
			else:
				torch_extinguish()

		elif name == "Lantern":
			activated = !activated
			if activated:
				lantern_ignite()
			else:
				lantern_extinguish()
		else:
			print("No associated 'on_use' action.")
			pass
	else:
		#Dynamic item you can pick up
		var inv = get_tree().root.get_node("Level/Player/Hud/Menu/TabBar/Inventory")
		inv.pickup(self)

func on_held():
	if is_inside_tree():
		freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
		$CollisionShape3D.disabled = true
	else:
		print("Error: ", name, "Item not inside the tree. Missing add_child()" +
				"after instantiation in player.gd?")

func on_drop():
	print("PhysicalItem.gd: ", name, " dropped.")
	if name == "Torch":
		torch_extinguish()
	if name == "Lantern":
		lantern_extinguish()
	pass

func lantern_ignite() -> void:
	$OmniLight3D.visible = true
	$OmniLight3D/AnimationPlayer.play()
	$GlassTopLit.visible = true
	$GlassBottomLit.visible = true
	$GlassTopDark.visible = false
	$GlassBottomDark.visible = false

func lantern_extinguish() -> void:
	$OmniLight3D.visible = false
	$OmniLight3D/AnimationPlayer.stop()
	$GlassTopLit.visible = false
	$GlassBottomLit.visible = false
	$GlassTopDark.visible = true
	$GlassBottomDark.visible = true



func torch_ignite() -> void:
	$Torch/Fire.visible = true
	$Torch/Dim.visible = false
	$Torch/Fire/Flame.emitting = true
	$Torch/Fire/Flame/OmniLight3D/AnimationPlayer.play()

func torch_extinguish() -> void:
	$Torch/Fire.visible = false
	$Torch/Dim.visible = true
	$Torch/Fire/Flame.emitting = false
	$Torch/Fire/Flame/OmniLight3D/AnimationPlayer.stop()

func make_upright():
		# had to give up for now and adjust manually
		pass
