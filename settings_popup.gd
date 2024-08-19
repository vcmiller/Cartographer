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
@onready var main_menu_button: Button = $MarginContainer/Panel/VBoxContainer/MainMenuButton
const mm_string = "Return to Main Menu"
const mm_string_2 = "Are You Sure?"

func _ready() -> void:
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if !visible and enabled and get_tree().current_scene.scene_file_path != "res://main_menu.tscn": 
			display()
		elif visible:
			hide()
		
		
func display():
	show()
	last_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 
	main_menu_button.text = mm_string
	main_menu_button.visible = get_tree().current_scene.scene_file_path != "res://main_menu.tscn"

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


func _on_main_menu_button_pressed() -> void:
	if main_menu_button.text == mm_string:
		main_menu_button.text = mm_string_2
	else:
		get_tree().change_scene_to_file("res://main_menu.tscn")
		hide()
	pass # Replace with function body.
