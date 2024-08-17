extends Node

@export var image: Image 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MapGridHandler.ParseImage(image)
	queue_free()
	pass # Replace with function body.
