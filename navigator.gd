extends CharacterBody3D
  
@onready var target: Node3D = %Target

#debug nonsense: ignore
func draw_path(img: Image, from: Vector2i, to: Vector2i, color: Color):
	var path = MapGridHandler.grid.get_point_path(from,to)
	for node in path: img.set_pixelv(node, color)
	
func vec2i(from: Vector3): return Vector2i(roundi(from.x), roundi(from.z))	
func vec3(from: Vector2i): return Vector3(from.x,position.y,from.y)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:  
	var path = MapGridHandler.grid.get_point_path(vec2i(position),vec2i(target.position), true)
	var target_pos := position
	if len(path) == 0: return
	elif len(path) == 1: target_pos = vec3(path[0])
	else: 
		target_pos = vec3(path[1])
		var dist_0 = position.distance_to(vec3(path[0]))
		#var dist_1 = position.distance_to(vec3(path[1]))
		target_pos = lerp(vec3(path[0]), vec3(path[1]), sqrt(2) - dist_0)
	#position = position.move_toward(target_pos, 10 * delta)
	velocity = position.direction_to(target_pos) * 10 #min(position.distance_to(target_pos),  10)
	move_and_slide()
	pass
