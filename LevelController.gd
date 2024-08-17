extends Node3D

@onready var spectator_camera: Camera3D = $SpectatorCamera
@onready var playback_canvas: PlaybackCanvas = $PlaybackCanvas
@onready var player_canvas: PlayerCanvas = $PlayerCanvas

@export var navigator_spawn_points: Array[NavigatorSpawn]
@export var player_scene: PackedScene
@export var Map: EditableMap

var player: PlayerController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_birth_player() 
	
func _birth_player():
	player = player_scene.instantiate()
	add_child(player)
	player.position = navigator_spawn_points[0].position
	player.player_canvas = player_canvas
	player.Map = Map
	player.CameraNode.make_current()
	player.connect("begin_trial",_on_player_begin_trial)

func _on_player_begin_trial(image: Image) -> void:
	player.queue_free()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player_canvas.hide()
	playback_canvas.activate()
	
	MapGridHandler.ParseImage(image)
	%TextureRect.texture = ImageTexture.create_from_image(image)
	
	for nsp in navigator_spawn_points: nsp.spawn_navigator() 
