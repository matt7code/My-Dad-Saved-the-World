extends Node

var item_data: Dictionary

func _ready():
	item_data = load_data("res://Data/JSON_ItemData.json")
	if item_data:
		print("JSON data loaded successfully:", item_data)
	else:
		print("Failed to load JSON data.")

func load_data(file_path: String) -> Dictionary:
	var json_data = {}
	var file = FileAccess.open(file_path, FileAccess.READ)

	# Open the file in read mode
	if !file:
		print("Error opening file:", file_path)
		return json_data

	# Read the entire file as text
	var json_text = file.get_as_text()
	file.close()

	# Parse the JSON text into a Dictionary or Array
	var json_parser = JSON.new()
	var result = json_parser.parse(json_text)

	if result.error != OK:
		print("Error parsing JSON:", result.error)
	else:
		json_data = result.result

	return json_data
