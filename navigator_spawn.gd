extends Marker3D
class_name NavigatorSpawn

@export var navigator_scene: PackedScene

func spawn_navigator(map: EditableMap, level: LevelController, goal: Goal, goalIndex: int) -> Navigator: 
	var navigator_inst = navigator_scene.instantiate() as Navigator
	get_parent().add_child(navigator_inst)
	navigator_inst.position = position
	navigator_inst.rotation = rotation
	navigator_inst.destIndex = goalIndex
	navigator_inst.level_controller = level
	navigator_inst.goal = goal
	navigator_inst.create_grid(map)
	return navigator_inst
