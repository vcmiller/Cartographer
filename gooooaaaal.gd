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
@export var show_on_die: Node3D
@export var remove_water_origin: Node3D
@export var remove_water_radius: float

var is_dead: bool
var show_on_die_parent: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trigger.connect("body_entered", _on_trigger_body_entered)
	if anim_player and idle_anim:
		anim_player.play(idle_anim)
		
	if show_on_die:
		show_on_die_parent = show_on_die.get_parent()
		show_on_die_parent.remove_child.call_deferred(show_on_die)

func _on_trigger_body_entered(body: Node3D):
	if body is Navigator:
		(body as Navigator).check_goal(self)
		
func die():
	if anim_player and die_anim:
		anim_player.play(die_anim)
	is_dead = true 
	await get_tree().create_timer(die_delay).timeout
	if show_on_die and show_on_die_parent:
		show_on_die_parent.add_child(show_on_die)
	get_parent().remove_child(self)
