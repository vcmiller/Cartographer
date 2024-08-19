extends CharacterBody3D
class_name PlayerController

signal begin_trial(map: EditableMap)
signal flag_marker_placed(index: int, position: Vector3)

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var CameraNode: Camera3D
@export var LookLimit: float = 80
@export var MouseSensitivity: float = 0.5
@export var MouseBoundWhenNotCaptured: float = 0.1
@export var LookSpeedWhenNotCaptured = 1
@export var Map: EditableMap
@export var MapItemInst: MapItem
@export var player_canvas: PlayerCanvas

@onready var item_manager: ItemManager = $Camera3D/ItemManager 
@onready var footstep_player: AudioStreamPlayer = $FootstepPlayer

var lastMousePos: Vector2
var eulerAngles: Vector3
var distanceWalked: float

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	eulerAngles = CameraNode.global_rotation
	if player_canvas: item_manager.selected_item_changed.connect(player_canvas.on_selected_item_changed)
	SettingsPopup.sensitivity_value_changed.connect(on_sensitivity_changed)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			var delta = event.screen_relative * MouseSensitivity * -PI / 180
			eulerAngles.x = clamp(eulerAngles.x + delta.y, -LookLimit * PI / 180, LookLimit * PI / 180)
			eulerAngles.y += delta.x
			CameraNode.rotation = Vector3(eulerAngles.x, 0, 0)
			rotation = Vector3(0, eulerAngles.y, 0)
		
		lastMousePos = event.position
	
	if event.is_action_pressed("map_submit"):
		if item_manager.currentItem is MapItem:
			item_manager.SetItem(null)
		else:
			item_manager.SetItem(item_manager.Items[0])
		
func submit():
	begin_trial.emit(Map)
	
func _process(delta: float) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		pass
		#var size = get_viewport().size
		#
		#var bound = MouseBoundWhenNotCaptured * size.y
		#var rotDelta = Vector3(0, 0, 0)
		#if lastMousePos.x < bound:
			#rotDelta.y += LookSpeedWhenNotCaptured * delta
		#if lastMousePos.x > size.x - bound:
			#rotDelta.y -= LookSpeedWhenNotCaptured * delta
		#if lastMousePos.y < bound:
			#rotDelta.x += LookSpeedWhenNotCaptured * delta
		#if lastMousePos.y > size.y - bound:
			#rotDelta.x -= LookSpeedWhenNotCaptured * delta
		#
		#eulerAngles.x = clamp(eulerAngles.x + rotDelta.x, -LookLimit * PI / 180, LookLimit * PI / 180)
		#eulerAngles.y += rotDelta.y
		#CameraNode.rotation = Vector3(eulerAngles.x, 0, 0)
		#rotation = Vector3(0, eulerAngles.y, 0)
func on_sensitivity_changed(value):
	MouseSensitivity = value / 100
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		distanceWalked += velocity.length() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_l", "move_r", "move_f", "move_b")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if not footstep_player.playing: footstep_player.play_random()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _on_map_item_flag_marker_placed(index: int, position: Vector3) -> void:
	flag_marker_placed.emit(index,position)
	pass # Replace with function body.
