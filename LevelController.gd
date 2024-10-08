extends Node3D
class_name LevelController

@onready var playback_canvas: PlaybackCanvas = $PlaybackCanvas
@onready var player_canvas: PlayerCanvas = $PlayerCanvas

@export var navigator_spawn_points: Array[NavigatorSpawn]
@export var player: PlayerController
@export var goals: Array[Goal]
@export var extraMarkerSprites: Array[Texture2D]
@export var extraMarkerPositions: Array[Node3D]
@export var remove_items: Array[int]
@export_file(".tscn") var nextLevel: String
@export var has_water: bool

@export var info_title: String
@export var info_portrait: Texture2D
@export_multiline var info_text: String
@export var attemps_for_3_stars: int = 3
@export var attemps_for_2_stars: int = 6

static var savedMap: EditableMap
static var attempts: int

var navigator_count: int
var has_failed: bool

signal update_map()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_canvas.player = player
	_birth_player()
	
func _birth_player():
	if player.get_parent() != self:
		player.get_parent().remove_child(player)
		add_child(player)
		
	remove_items.sort_custom(func(a, b): return b - a)
	for r in remove_items:
		player.item_manager.Items.pop_at(r)
	
	var didLoad = false
	if savedMap and savedMap.Width == player.Map.Width and savedMap.Height == player.Map.Height:
		player.Map = savedMap
		savedMap = null
		didLoad = true
		attempts += 1
	else:
		player.Map = player.Map.duplicate()
		for i in range(len(goals)):
			if goals[i].start_marked:
				player.Map.markerLocations.append(goals[i].position)
				player.Map.markersPlaced.append(true)
			else:
				player.Map.markerLocations.append(Vector3.ZERO)
				player.Map.markersPlaced.append(false)
		attempts = 1
		
	for i in range(len(goals)):
		player.MapItemInst.markerSprites.append(goals[i].marker_sprite)
		player.MapItemInst.markersLocked.append(goals[i].start_marked)
	for i in range(len(extraMarkerSprites)):
		player.MapItemInst.extraMarkerPositions.append(extraMarkerPositions[i].position)
		player.MapItemInst.extraMarkerSprites.append(extraMarkerSprites[i])
		
	if not has_water:
		player.MapItemInst.WaterToolButton.get_parent().remove_child(player.MapItemInst.WaterToolButton)
		
	player.player_canvas = player_canvas
	player.CameraNode.make_current()
	player.connect("begin_trial",_on_player_begin_trial)
	
	player_canvas.show_info(info_portrait, info_title, info_text, not didLoad)
	
func SaveMap():
	savedMap = player.Map

func _on_player_begin_trial(map: EditableMap) -> void:
	remove_child(player)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player_canvas.hide()
	playback_canvas.activate()
	
	var navigators : Array[Navigator] = []
	for i in range(len(navigator_spawn_points)):
		var nsp = navigator_spawn_points[i]
		var navigator = nsp.spawn_navigator(map, self, goals[i], i)
		navigators.append(navigator)
		navigator_count += 1
	playback_canvas.update_viewports(navigators)
	
func fail():
	if has_node("DragonRoar"): $"DragonRoar".play(1)
	has_failed = true
	
func succccess():
	navigator_count -= 1
	if navigator_count <= 0 and not has_failed:
		playback_canvas.on_victory()
	update_map.emit()
