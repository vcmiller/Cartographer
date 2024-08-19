extends Marker3D
class_name NavigatorSpawn

@export var navigator_scene: PackedScene
@export var special_props: Array[String]

func spawn_navigator(map: EditableMap, level: LevelController, goal: Goal, goalIndex: int) -> Navigator: 
	var navigator_inst = navigator_scene.instantiate() as Navigator
	navigator_inst.position = position
	navigator_inst.rotation = rotation
	navigator_inst.destIndex = goalIndex
	navigator_inst.level_controller = level
	navigator_inst.goal = goal
	get_parent().add_child(navigator_inst)
	navigator_inst.create_grid(map)
	
	for p in special_props:
		navigator_inst.Model.get_node(p).show()
	
	return navigator_inst
