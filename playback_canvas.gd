extends CanvasLayer
class_name PlaybackCanvas

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
@onready var CameraBL: Camera3D = $HBoxContainer/Left/BL_Parent/BL/SubViewport2/CameraBL
@onready var CameraTR: Camera3D = $HBoxContainer/Right/TR_Parent/TR/SubViewport3/CameraTR
@onready var CameraBR: Camera3D = $HBoxContainer/Right/BR_Parent/BR/SubViewport4/CameraBR
@onready var CheckmarkTL: Control = $HBoxContainer/Left/TL_Parent/CheckMark
@onready var CheckmarkBL: Control = $HBoxContainer/Left/BL_Parent/CheckMark
@onready var CheckmarkTR: Control = $HBoxContainer/Right/TR_Parent/CheckMark
@onready var CheckmarkBR: Control = $HBoxContainer/Right/BR_Parent/CheckMark
@onready var SkullTL: Control = $HBoxContainer/Left/TL_Parent/Skull
@onready var SkullBL: Control = $HBoxContainer/Left/BL_Parent/Skull
@onready var SkullTR: Control = $HBoxContainer/Right/TR_Parent/Skull
@onready var SkullBR: Control = $HBoxContainer/Right/BR_Parent/Skull
@onready var Star1: Control = $WinScreen/Panel/StarParent1/Star1
@onready var Star2: Control = $WinScreen/Panel/StarParent2/Star2
@onready var Star3: Control = $WinScreen/Panel/StarParent3/Star3
@onready var attemps_label: Label = $WinScreen/Panel/Label
@onready var new_best_label: Label = $WinScreen/Panel/NewBestLabel
@onready var viewport_all_parent: Control = $HBoxContainer

var checkmarks: Array[Control]
var skulls: Array[Control]
var navigators: Array[Navigator]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("map_submit") and is_visible():
		retry()
		
func retry():
	level_controller.SaveMap()
	get_tree().reload_current_scene()
	
func reset():
	level_controller.savedMap = null
	get_tree().reload_current_scene()
		
func _ready() -> void:
	ViewportsLeft.hide()
	ViewportsRight.hide()
	win_screen.hide()
	CheckmarkBL.hide()
	CheckmarkTL.hide()
	CheckmarkBR.hide()
	CheckmarkTR.hide()
	SkullTL.hide()
	SkullBL.hide()
	SkullTR.hide()
	SkullBR.hide()
	Star1.hide()
	Star2.hide()
	Star3.hide()
	new_best_label.hide()
	
	ViewportParentTL.resized.connect(func(): fix_viewport_scale(ViewportParentTL))
	ViewportParentBL.resized.connect(func(): fix_viewport_scale(ViewportParentBL))
	ViewportParentTR.resized.connect(func(): fix_viewport_scale(ViewportParentTR))
	ViewportParentBR.resized.connect(func(): fix_viewport_scale(ViewportParentBR))
	
func get_ui_scale() -> float:
	return viewport_all_parent.size.y / get_viewport().size.y
	
func fix_viewport_scale(viewport_parent: Control):
	var container = viewport_parent.get_child(0) as SubViewportContainer
	
	var ui_scale = get_ui_scale()
	container.scale = Vector2(ui_scale, ui_scale)
	container.set_size(viewport_parent.size / ui_scale)
	
func _process(delta: float) -> void:
	if not visible: return
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if navigators and checkmarks:
		for i in range(len(navigators)):
			checkmarks[i].visible = navigators[i].goal.is_dead and not navigators[i].is_dead
			skulls[i].visible = navigators[i].is_dead

func on_victory():
	win_screen.show()
	victory_sound.play()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	attemps_label.text = "Attempts: " + str(LevelController.attempts)
	var stars: int
	if LevelController.attempts > level_controller.attemps_for_2_stars:
		stars = 1
	elif LevelController.attempts > level_controller.attemps_for_3_stars:
		stars = 2
	else:
		stars = 3
		
	var star_dict = SaveStateManger.get_star_dict()
	var scene = get_tree().current_scene.name
	
	var is_new_best = true
	if scene in star_dict:
		var old_best = star_dict[scene] as int
		if stars <= old_best:
			is_new_best = false
			
	if is_new_best:
		star_dict[scene] = stars
		SaveStateManger.set_star_dict(star_dict)
		
	await get_tree().create_timer(0.5).timeout
	if not is_inside_tree(): return
	animate_star(Star1)
	
	if stars > 1:
		await get_tree().create_timer(0.5).timeout
		if not is_inside_tree(): return
		animate_star(Star2)
	
	if stars > 2:
		await get_tree().create_timer(0.5).timeout
		if not is_inside_tree(): return
		animate_star(Star3)
		
	if is_new_best:
		await get_tree().create_timer(0.5).timeout
		if not is_inside_tree(): return
		animate_star(new_best_label)
		
func animate_star(star: Control):
	star.show()
	var start_scale = Vector2(5, 5)
	star.scale = start_scale
	
	var elapsed = 0
	await get_tree().process_frame
	if not is_inside_tree(): return
	while elapsed < 0.5:
		elapsed += get_process_delta_time()
		star.scale = start_scale.lerp(Vector2(1, 1), elapsed * 2.0)
		await get_tree().process_frame
		if not is_inside_tree(): return
		
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
		skulls = [SkullTL]
	elif count == 2:
		ViewportsLeft.show()
		ViewportsRight.show()
		ViewportParentTL.show()
		ViewportParentBL.hide()
		ViewportParentTR.show()
		ViewportParentBR.hide()
		cameras = [CameraTL, CameraTR]
		checkmarks = [CheckmarkTL, CheckmarkTR]
		skulls = [SkullTL, SkullTR]
	elif count == 3:
		ViewportsLeft.show()
		ViewportsRight.show()
		ViewportParentTL.show()
		ViewportParentBL.show()
		ViewportParentTR.show()
		ViewportParentBR.hide()
		cameras = [CameraTL, CameraBL, CameraTR]
		checkmarks = [CheckmarkTL, CheckmarkBL, CheckmarkTR]
		skulls = [SkullTL, SkullBL, SkullTR]
	else:
		ViewportsLeft.show()
		ViewportsRight.show()
		ViewportParentTL.show()
		ViewportParentBL.show()
		ViewportParentTR.show()
		ViewportParentBR.show()
		cameras = [CameraTL, CameraBL, CameraTR, CameraBR]
		checkmarks = [CheckmarkTL, CheckmarkBL, CheckmarkTR, CheckmarkBR]
		skulls = [SkullTL, SkullBL, SkullTR, SkullBR]
		
	for i in range(count):
		navigators[i].remote.remote_path = cameras[i].get_path()

func activate():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	show()

func deactivate():
	hide()


func _on_next_button_pressed() -> void:
	get_tree().change_scene_to_file(level_controller.nextLevel)
