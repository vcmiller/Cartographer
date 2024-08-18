extends Node3D
class_name Goal

@export var trigger: Area3D
@export var is_hazard: bool
@export var hazard_radius: float
@export var marker_sprite: Texture2D
@export var start_marked: bool
@export var anim_player: AnimationPlayer
@export var idle_anim: String
@export var die_anim: String
@export var die_delay: float

var is_dead: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trigger.connect("body_entered", _on_trigger_body_entered)
	if anim_player and idle_anim:
		anim_player.play(idle_anim)

func _on_trigger_body_entered(body: Node3D):
	if body is Navigator:
		(body as Navigator).check_goal(self)
		
func die():
	if anim_player and die_anim:
		anim_player.play(die_anim)
	is_dead = true
	await get_tree().create_timer(die_delay).timeout
	get_parent().remove_child(self)
