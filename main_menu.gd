extends Control

@onready var levels_to_select: HBoxContainer = $CenterContainer/VBoxContainer/LevelsToSelect
@onready var quit_button: Button = $CenterContainer/VBoxContainer/Quit

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	quit_button.visible = OS.get_name() != "Web"

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/level1.tscn")
	pass # Replace with function body.


func _on_level_select_pressed(toggled_on) -> void:
	levels_to_select.visible = toggled_on
	if toggled_on:
		var tween = create_tween()
		tween.tween_property(levels_to_select,"theme_override_constants/separation",12,0.1).from(-64)
		tween.play()
	pass # Replace with function body.


func _on_settings_pressed() -> void:
	SettingsPopup.display()
	pass # Replace with function body.
	
func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://credits.tscn")
	
func _on_quit_pressed() -> void:
	get_tree().quit()
