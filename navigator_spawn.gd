extends Marker3D
class_name NavigatorSpawn

@export var navigator_scene: PackedScene
@export var special_props: Array[String]
@export var special_prop_attach_points: Array[int]

func spawn_navigator(map: EditableMap, level: LevelController, goal: Goal, goalIndex: int) -> Navigator: 
	var navigator_inst = navigator_scene.instantiate() as Navigator
	navigator_inst.position = position
	navigator_inst.rotation = rotation
	navigator_inst.destIndex = goalIndex
	navigator_inst.level_controller = level
	navigator_inst.goal = goal
	get_parent().add_child(navigator_inst)
	navigator_inst.create_grid(map)
	
	for i in range(len(special_props)):
		var p = special_props[i]
		var node = navigator_inst.Model.get_node(p)
		node.show()
		var t = node.global_transform
		navigator_inst.Model.remove_child(node)
		navigator_inst.attach_points[special_prop_attach_points[i]].add_child(node)
		node.global_transform = t
	
	return navigator_inst
