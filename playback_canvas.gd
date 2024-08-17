extends CanvasLayer
class_name PlaybackCanvas

@onready var fuck_label: Label = $FuckLabel

@export var level_controller: LevelController

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("map_submit") and is_visible(): 
		level_controller.SaveMap()
		get_tree().reload_current_scene()

func activate():
	show()
	fuck_label.hide()

func deactivate():
	hide()
