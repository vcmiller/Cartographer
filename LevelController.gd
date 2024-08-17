extends Node3D

@onready var spectator_camera: Camera3D = $SpectatorCamera
@onready var player: CharacterBody3D = $Player

@export var navigator_spawn_points: Array[NavigatorSpawn]
@export var player_scene: PackedScene

@onready var playback_canvas: PlaybackCanvas = $PlaybackCanvas

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _birth_player():
	player = player_scene.instantiate()
	add_child(player)
	player.position = navigator_spawn_points[0].position

func _on_player_begin_trial(image: Image) -> void:
	player.queue_free()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	playback_canvas.activate()
	
	MapGridHandler.ParseImage(image)
	%TextureRect.texture = ImageTexture.create_from_image(image)
	
	for nsp in navigator_spawn_points: nsp.spawn_navigator() 
