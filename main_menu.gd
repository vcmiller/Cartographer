extends Control

 


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/level1.tscn")
	pass # Replace with function body.


func _on_level_select_pressed() -> void:
	pass # Replace with function body.


func _on_settings_pressed() -> void:
	SettingsPopup.show()
	pass # Replace with function body.
