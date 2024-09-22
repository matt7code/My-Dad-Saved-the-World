extends Node

var item_data: Dictionary

func _ready():
	item_data = LoadData("res://Data/JSON_ItemData.gd")

func LoadData(file_path):
	var json_data
	var file_data = File.new()

	file_data.open(file_path, File.READ)
	var test_json_conv = JSON.new()
	test_json_conv.parse(file_data.get_as_text())
	json_data = test_json_conv.get_data()
	file_data.close()
	return json_data.result
