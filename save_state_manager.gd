class_name SaveStateManger

static func set_star_dict(stars: Dictionary):
	var save_file = FileAccess.open("user://stars.save", FileAccess.WRITE)
	var json_string = JSON.stringify(stars)

	save_file.store_line(json_string)

static func get_star_dict() -> Dictionary:
	var file = FileAccess.open("user://stars.save", FileAccess.READ)
	
	if not file:
		return {}
	
	var json_string = file.get_line()
	
	return JSON.parse_string(json_string)
