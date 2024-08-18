extends CanvasLayer
class_name PlaybackCanvas

@onready var fuck_label: Label = $FuckLabel
@onready var win_label: Label = $WinLabel

@export var level_controller: LevelController
@export var ViewportsLeft: CanvasItem
@export var ViewportsRight: CanvasItem
@export var ViewportParentTL: SubViewportContainer
@export var ViewportParentBL: SubViewportContainer
@export var ViewportParentTR: SubViewportContainer
@export var ViewportParentBR: SubViewportContainer
@export var CameraTL: Camera3D
@export var CameraTR: Camera3D
@export var CameraBL: Camera3D
@export var CameraBR: Camera3D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("map_submit") and is_visible():
		retry()
		
func retry():
	level_controller.SaveMap()
	get_tree().reload_current_scene()
		
func _ready() -> void:
	ViewportsLeft.hide()
	ViewportsRight.hide()
		
func update_viewports(navigators: Array[Navigator]):
	var count = len(navigators)
	if count == 0 or count > 4:
		printerr("must have at least one and at most 4 navigators.")
	
	var cameras: Array[Camera3D]
	if count == 1:
		ViewportsLeft.show()
		ViewportsRight.hide()
		ViewportParentTL.show()
		ViewportParentBL.hide()
		cameras = [CameraTL]
	elif count == 2:
		ViewportsLeft.show()
		ViewportsRight.show()
		ViewportParentTL.show()
		ViewportParentBL.hide()
		ViewportParentTR.show()
		ViewportParentBR.hide()
		cameras = [CameraTL, CameraTR]
	elif count == 3:
		ViewportsLeft.show()
		ViewportsRight.show()
		ViewportParentTL.show()
		ViewportParentBL.show()
		ViewportParentTR.show()
		ViewportParentBR.hide()
		cameras = [CameraTL, CameraBL, CameraTR]
	else:
		ViewportsLeft.show()
		ViewportsRight.show()
		ViewportParentTL.show()
		ViewportParentBL.show()
		ViewportParentTR.show()
		ViewportParentBR.show()
		cameras = [CameraTL, CameraBL, CameraTR, CameraBR]
		
	for i in range(count):
		navigators[i].remote.remote_path = cameras[i].get_path()

func activate():
	show()
	fuck_label.hide()

func deactivate():
	hide()


func _on_next_button_pressed() -> void:
	get_tree().change_scene_to_file(level_controller.nextLevel)
