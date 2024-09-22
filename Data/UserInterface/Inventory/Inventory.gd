extends TabBar

const SlotClass = preload("res://UserInterface/Inventory/Slot.gd")
const InventoryItem = preload("res://Items/InventoryItem.tscn")

@onready var backpack = $Backpack
@onready var paper_doll = $PaperDoll

var holding_item
@onready var menu = $"../../"

func _ready() -> void:

	Global.drop_node = Node3D.new()
	Global.drop_node.name = "Dropped"
	get_tree().root.call_deferred("add_child", Global.drop_node)


	if !Global.drop_node:
		print("Inv: Failed to add drop_node")

	for inv_slot in backpack.get_children():
		inv_slot.connect("gui_input", Callable(self, "slot_gui_input").bind(inv_slot))
	for inv_slot in paper_doll.get_children():
		inv_slot.connect("gui_input", Callable(self, "slot_gui_input").bind(inv_slot))
	if menu:
		menu.connect("gui_input", Callable(self, "drop_item"))
		print("Menu connected")
	else:
		print("Menu failed to connect in Inventory.gd")

func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			# Holding an item
			if holding_item != null:
				 # Empty Slot
				if !slot.item:
					slot.putInSlot(holding_item)
					holding_item = null
				# Slot contains an item
				else:
					# Different item, so swap
					if holding_item.item_id != slot.item.item_id:
						var temp_item = slot.item
						slot.pickFromSlot()
						temp_item.global_position = get_global_mouse_position() - Vector2(64, 64)
						slot.putInSlot(holding_item)
						holding_item = temp_item
					# Same item, so attempt to combine stacks
					else:
						var stack_size = holding_item.item_stacksize
						var able_to_add = stack_size - slot.item.item_quantity
						if able_to_add >= holding_item.item_quantity:
							slot.item.add_item_quantity(holding_item.item_quantity)
							holding_item.queue_free()
							holding_item = null
						else:
							slot.item.add_item_quantity(able_to_add)
							holding_item.subtract_item_quantity(able_to_add)
			# Not holding an item, so try to pick one up from slot
			elif slot.item:
				holding_item = slot.item
				slot.pickFromSlot()
				holding_item.global_position = get_global_mouse_position() - Vector2(64, 64)
			else:
				# Clicked an empty slot, with nothing in hand
				print("Clicked Empty")
				pass


func _input(event: InputEvent) -> void:
	if holding_item:
		holding_item.global_position = get_global_mouse_position() - Vector2(64, 64)

	if event.is_action_pressed("ui_inventory") and holding_item:
		var empty_slot = findEmptySlot()
		if empty_slot:
			empty_slot.putInSlot(holding_item)
			holding_item = null

func findEmptySlot():
	for inv_slot in backpack.get_children():
		if inv_slot.item == null:
			return inv_slot
	print("Error: No empty backpack slot found. Item retained on hand")
	return null

func drop_item(event):
	# Is in the inventory screen
	if menu.get_node("TabBar").current_tab == 0:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
				if holding_item:
					var dropped:Node3D = Global.items[holding_item.item_id].instantiate()
					if dropped:
						print("Dropping: ", holding_item.item_id, " ", dropped.name)
						Global.drop_node.add_child(dropped)
						dropped.global_transform = Global.player.global_transform
						dropped.translate(Vector3(0, 1, -1))
						dropped.rotate_x(15)
						dropped.sleeping = false
						if dropped.has_method("on_drop"):
							dropped.on_drop()
						holding_item.subtract_item_quantity(1)
						if holding_item.item_quantity == 0:
							holding_item.queue_free()
							holding_item = null
#							print("INV_drop: holding item = null")

						else:
#							print("INV_drop: ", holding_item.item_quantity)
							pass
					else:
#						print("Cannot drop '", holding_item.item_id, "'")
						pass
				else:
#					print("Inventory.gd: Nothing to drop, ", Global.player.name)
					pass
	else:
#		print("Cannot drop '", holding_item.item_id, "', not in inventory screen.")
		pass

func drop_coins():
	#different treatment?
	pass

func pickup(item):
	var item_id:String = item.filename
	item_id = item_id.trim_prefix("res://Items/")
	item_id = item_id.trim_suffix(".tscn")
	item_id = item_id.to_lower()
	print(item.name, ' - ', item.filename, " - ", item_id)

	# Construct a 'holding_item' inventory item representation of the physical item
	holding_item = InventoryItem.instantiate()
	holding_item.set_item(item_id)

	# Stick it in
	var empty_slot = findEmptySlot()
	if empty_slot:
		#get rid of physical item
		item.queue_free()
		empty_slot.putInSlot(holding_item)
		holding_item = null
	else:
		print("No room. Say: 'I can't carry this!' or something.")
