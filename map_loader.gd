extends Node

@export var texture: Texture2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MapGridHandler.ParseImage(texture.get_image())
	queue_free()
	pass # Replace with function body.
