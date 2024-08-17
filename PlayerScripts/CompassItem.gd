extends ItemBase

@export var RootTransform: Node3D
@export var Needle: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var yaw = RootTransform.rotation.y
	Needle.rotation = Vector3(0, -yaw, 0)
