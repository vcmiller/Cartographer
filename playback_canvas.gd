extends CanvasLayer
class_name PlaybackCanvas

@onready var fuck_label: Label = $FuckLabel
@onready var win_screen: Control = $WinScreen
@onready var victory_sound: AudioStreamPlayer = $VictorySound

@export var level_controller: LevelController
@onready var ViewportsLeft: CanvasItem = $HBoxContainer/Left
@onready var ViewportsRight: CanvasItem = $HBoxContainer/Right
@onready var ViewportParentTL: Control = $HBoxContainer/Left/TL_Parent
@onready var ViewportParentBL: Control = $HBoxContainer/Left/BL_Parent
@onready var ViewportParentTR: Control = $HBoxContainer/Right/TR_Parent
@onready var ViewportParentBR: Control = $HBoxContainer/Right/BR_Parent
@onready var CameraTL: Camera3D = $HBoxContainer/Left/TL_Parent/TL/SubViewport/CameraTL
@onready var CameraBL: Camera3D = $HBoxContainer/Left/BL_Parent/BL/SubViewport/CameraBL
@onready var CameraTR: Camera3D = $HBoxContainer/Right/TR_Parent/TR/SubViewport/CameraTR
@onready var CameraBR: Camera3D = $HBoxContainer/Right/BR_Parent/BR/SubViewport/CameraBR
@onready var CheckmarkTL: Control = $HBoxContainer/Left/TL_Parent/TextureRect
@onready var CheckmarkTR: Control = $HBoxContainer/Left/BL_Parent/TextureRect
@onready var CheckmarkBL: Control = $HBoxContainer/Right/TR_Parent/TextureRect
@onready var CheckmarkBR: Control = $HBoxContainer/Right/BR_Parent/TextureRect
@onready var Star1: Control = $WinScreen/Panel/StarParent1/Star1
@onready var Star2: Control = $WinScreen/Panel/StarParent2/Star2
@onready var Star3: Control = $WinScreen/Panel/StarParent3/Star3
@onready var attemps_label: Label = $WinScreen/Panel/Label

var checkmarks: Array[Control]
var navigators: Array[Navigator]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("map_submit") and is_visible():
		retry()
		
func retry():
	level_controller.SaveMap()
	get_tree().reload_current_scene()
		
func _ready() -> void:
	ViewportsLeft.hide()
	ViewportsRight.hide()
	win_screen.hide()
	CheckmarkBL.hide()
	CheckmarkTL.hide()
	CheckmarkBR.hide()
	CheckmarkTR.hide()
	Star1.hide()
	Star2.hide()
	Star3.hide()
	
func _process(delta: float) -> void:
	if navigators and checkmarks:
		for i in range(len(navigators)):
			checkmarks[i].visible = navigators[i].goal.is_dead

func on_victory():
	win_screen.show()
	victory_sound.play()
	
	attemps_label.text = "Attemps: " + str(LevelController.attempts)
	var stars: int
	if LevelController.attempts > level_controller.attemps_for_2_stars:
		stars = 1
	elif LevelController.attempts > level_controller.attemps_for_3_stars:
		stars = 2
	else:
		stars = 3
		
	await get_tree().create_timer(0.5).timeout
	animate_star(Star1)
	
	if stars < 2: return
	
	await get_tree().create_timer(0.5).timeout
	animate_star(Star2)
	
	if stars < 3: return
	
	await get_tree().create_timer(0.5).timeout
	animate_star(Star3)
		
func animate_star(star: Control):
	star.show()
	var start_scale = Vector2(5, 5)
	star.scale = start_scale
	
	var elapsed = 0
	await get_tree().process_frame
	while elapsed < 0.5:
		elapsed += get_process_delta_time()
		star.scale = start_scale.lerp(Vector2(1, 1), elapsed * 2.0)
		await get_tree().process_frame
		
	star.scale = Vector2(1, 1)
		
func update_viewports(navigators: Array[Navigator]):
	var count = len(navigators)
	if count == 0 or count > 4:
		printerr("must have at least one and at most 4 navigators.")
	self.navigators = navigators
	
	var cameras: Array[Camera3D]
	if count == 1:
		ViewportsLeft.show()
		ViewportsRight.hide()
		ViewportParentTL.show()
		ViewportParentBL.hide()
		cameras = [CameraTL]
		checkmarks = [CheckmarkTL]
	elif count == 2:
		ViewportsLeft.show()
		ViewportsRight.show()
		ViewportParentTL.show()
		ViewportParentBL.hide()
		ViewportParentTR.show()
		ViewportParentBR.hide()
		cameras = [CameraTL, CameraTR]
		checkmarks = [CheckmarkTL, CheckmarkTR]
	elif count == 3:
		ViewportsLeft.show()
		ViewportsRight.show()
		ViewportParentTL.show()
		ViewportParentBL.show()
		ViewportParentTR.show()
		ViewportParentBR.hide()
		cameras = [CameraTL, CameraBL, CameraTR]
		checkmarks = [CheckmarkTL, CheckmarkBL, CheckmarkTR]
	else:
		ViewportsLeft.show()
		ViewportsRight.show()
		ViewportParentTL.show()
		ViewportParentBL.show()
		ViewportParentTR.show()
		ViewportParentBR.show()
		cameras = [CameraTL, CameraBL, CameraTR, CameraBR]
		checkmarks = [CheckmarkTL, CheckmarkBL, CheckmarkTR, CheckmarkBR]
		
	for i in range(count):
		navigators[i].remote.remote_path = cameras[i].get_path()

func activate():
	show()
	fuck_label.hide()

func deactivate():
	hide()


func _on_next_button_pressed() -> void:
	get_tree().change_scene_to_file(level_controller.nextLevel)
