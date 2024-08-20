extends Area3D
signal navigator_detected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_body_entered(body: Node3D) -> void:
	if body is Navigator:
		(body as Navigator).touch_water()
