extends Node3D
class_name LevelController

@onready var playback_canvas: PlaybackCanvas = $PlaybackCanvas
@onready var player_canvas: PlayerCanvas = $PlayerCanvas

@export var navigator_spawn_points: Array[NavigatorSpawn]
@export var player: PlayerController

static var savedMap: EditableMap

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_birth_player() 
	
func _birth_player():
	if player.get_parent() != self:
		player.get_parent().remove_child(player)
		add_child(player)
		
	if savedMap and savedMap.Width == player.Map.Width and savedMap.Height == player.Map.Height:
		player.Map = savedMap
		savedMap = null
		
	player.player_canvas = player_canvas
	player.CameraNode.make_current()
	player.connect("begin_trial",_on_player_begin_trial)
	
func SaveMap():
	savedMap = player.Map

func _on_player_begin_trial(image: Image) -> void:
	remove_child(player)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player_canvas.hide()
	playback_canvas.activate()
	
	MapGridHandler.ParseImage(image)
	
	var navigators : Array[Navigator] = []
	for nsp in navigator_spawn_points:
		var navigator = nsp.spawn_navigator()
		navigators.append(navigator)
	playback_canvas.update_viewports(navigators)
