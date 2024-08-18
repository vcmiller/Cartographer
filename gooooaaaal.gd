extends Node3D
class_name Goal

@export var trigger: Area3D
@export var is_hazard: bool
@export var marker_sprite: Texture2D
@export var start_marked: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trigger.connect("body_entered", _on_trigger_body_entered)

func _on_trigger_body_entered(body: Node3D):
	if body is Navigator:
		(body as Navigator).check_goal(self)
