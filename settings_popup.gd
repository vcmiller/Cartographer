extends PopupPanel

signal bgm_slider_value_changed(value)
signal amb_slider_value_changed(value)
signal sfx_slider_value_changed(value)
signal sensitivity_value_changed(value)

@export var bgm_volume = 50
@export var amb_volume= 50
@export var sfx_volume= 50
@export var sensitivity = 50
@export var enabled = true

var last_mouse_mode: Input.MouseMode

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") \
	and enabled \
	and get_tree().current_scene.scene_file_path != "res://main_menu.tscn": 
		show()
		last_mouse_mode = Input.mouse_mode
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 

func _on_bgm_slider_value_changed(value: float) -> void:
	bgm_volume= value
	bgm_slider_value_changed.emit(value)
	pass # Replace with function body.


func _on_ambience_slider_value_changed(value: float) -> void:
	amb_volume = value
	amb_slider_value_changed.emit(value)
	pass # Replace with function body.


func _on_sfx_slider_value_changed(value: float) -> void:
	sfx_volume = value
	sfx_slider_value_changed.emit(value)
	pass # Replace with function body.

func _on_sensitivity_slider_value_changed(value: float) -> void:
	sensitivity = value
	sensitivity_value_changed.emit(value)
	pass # Replace with function body.

func _on_popup_hide() -> void:
	Input.mouse_mode = last_mouse_mode
	pass # Replace with function body.
