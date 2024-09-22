# Here, the 'item' represents a space in the backpack.
# If it is null, it's seen as empty and given a grey border.
# Slots get set to items if they have an item.

extends Panel

var inv_item = preload("res://Items/InventoryItem.tscn")
var stylebox_empty = preload("res://UserInterface/Inventory/SlotStyle_empty.tres")
var stylebox_item = preload("res://UserInterface/Inventory/SlotStyle_item.tres")
var stylebox_active = preload("res://UserInterface/Inventory/SlotStyle_active.tres")
var stylebox_selected = preload("res://UserInterface/Inventory/SlotStyle_selected.tres")
var active:= false
var selected:= false
var item = null


func _ready() -> void:
	var err = connect("mouse_entered", Callable(self, "mouse_entered"))
	err += connect("mouse_exited", Callable(self, "mouse_exited"))
	if err: print("Problem connecting mouse events in Slot.gd")
#	populate_slot()


func populate_slot():
	if randi() % 2:
		item = inv_item.instantiate()
		add_child(item)
	refresh_style()


func mouse_exited():
	active = false
	refresh_style()


func mouse_entered():
	active = true
	refresh_style()


func refresh_style():
	if item:
		if selected:
			set("theme_override_styles/panel", stylebox_selected)
		elif active:
			set("theme_override_styles/panel", stylebox_active)
		else:
			set("theme_override_styles/panel", stylebox_item)
	else:
		set("theme_override_styles/panel", stylebox_empty)


func pickFromSlot():
	print("Pick from slot")
	remove_child(item)
	var inventoryNode = find_parent("Inventory")
	inventoryNode.add_child(item)
	item = null
	refresh_style()


func putInSlot(new_item):
	print("Put in slot")
	item = new_item
	item.position = Vector2(0, 0)
	var inventoryNode = find_parent("Inventory")
	if inventoryNode.is_ancestor_of(item):
		inventoryNode.remove_child(item)
	add_child(item)
	refresh_style()
