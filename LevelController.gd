extends Node3D

@onready var navigator_spawn: Marker3D = $NavigatorSpawn
@onready var spectator_camera: Camera3D = $SpectatorCamera
@onready var player: CharacterBody3D = $Player
@onready var target: Marker3D = $Target

@export var navigator: PackedScene = load("res://navigator.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_begin_trial(image: Image) -> void:
	player.queue_free()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	image.resize(128,128)
	MapGridHandler.ParseImage(image)
	%TextureRect.texture = ImageTexture.create_from_image(image)
	
	var navigator_inst = navigator.instantiate()
	add_child(navigator_inst)
	navigator_inst.target = target
	navigator_inst.position = navigator_spawn.position
	pass # Replace with function body.
