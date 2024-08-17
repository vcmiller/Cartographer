extends Marker3D
class_name NavigatorSpawn

@export var target: Node3D
@export var navigator_scene: PackedScene

func spawn_navigator() -> Navigator: 
	var navigator_inst = navigator_scene.instantiate()
	get_parent().add_child(navigator_inst)
	navigator_inst.target = target
	navigator_inst.position = position
	return navigator_inst
