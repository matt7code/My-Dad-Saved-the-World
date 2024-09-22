extends Node2D

@onready var item_texture = $TextureRect
@onready var label = $TextureRect/Label

var item_id = "null"
var item_quantity = 1
var item_name = "null"
var item_stacksize = 1

func set_item(new_item_id):
	label = $TextureRect/Label
	item_texture = $TextureRect

	print("Setting up new Inventory Item: ", new_item_id)
	item_id = new_item_id
	item_name = str(JsonData.item_data[item_id]["ItemName"])
	item_stacksize = int(JsonData.item_data[item_id]["StackSize"])

	if item_stacksize == 1:

		label.visible = false
	else:
		label.text = str(item_quantity)

	item_texture.texture = load("res://Items/Icons/128x128/" + item_id + ".png")
	if !item_texture.texture:
		print("Error (Item.gd): Couldn't match an item_id given in Item.gd to an icon.")
	item_texture.offset_left = 10
	item_texture.offset_top = 10
	item_texture.offset_right = -10
	item_texture.offset_bottom = -10
	item_texture.position = Vector2(10, 10)
	item_texture.custom_minimum_size = Vector2(41, 41)
	item_texture.size = Vector2(108, 108)
	item_texture.expand = true
	item_texture.stretch_mode = TextureRect.STRETCH_SCALE

func add_item_quantity(amount_to_add):
	item_quantity += amount_to_add
	label.text = str(item_quantity)

func subtract_item_quantity(amount_to_subtract):
	item_quantity -= amount_to_subtract
	label.text = str(item_quantity)
