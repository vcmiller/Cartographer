extends CharacterBody3D
class_name Navigator
  
@export var target: Node3D 
@export var remote: RemoteTransform3D

@onready var lineDrawer: MeshInstance3D = $LineDrawer

const SPEED = 25

#debug nonsense: ignore
func draw_path(img: Image, from: Vector2i, to: Vector2i, color: Color):
	var path = MapGridHandler.grid.get_point_path(from,to)
	for node in path: img.set_pixelv(node, color)
	
func vec2i(from: Vector3): return Vector2i(roundi(from.x), roundi(from.z))	
func vec3(from: Vector2i): return Vector3(from.x,position.y,from.y)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:  
	if(not target): return
	var path = MapGridHandler.grid.get_point_path(vec2i(position),vec2i(target.position), true)
	
	var mesh : ImmediateMesh = lineDrawer.mesh
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	
	for i in range(len(path)):
		mesh.surface_add_vertex(vec3(path[i]))
	
	mesh.surface_end()
	
	var target_pos := position
	if len(path) == 0: return
	elif len(path) == 1: target_pos = vec3(path[0])
	else: 
		target_pos = vec3(path[1])
		var dist_0 = position.distance_to(vec3(path[0]))
		#var dist_1 = position.distance_to(vec3(path[1]))
		target_pos = lerp(vec3(path[0]), vec3(path[1]), sqrt(2) - dist_0)
	#position = position.move_toward(target_pos, 10 * delta)
	velocity = position.direction_to(target_pos) * SPEED #min(position.distance_to(target_pos),  10)
	if velocity.length_squared() > 0.1:
		var dir = velocity
		dir.y = 0
		var targetBasis = Basis.looking_at(dir)
		var targetQuaternion = targetBasis.get_rotation_quaternion()
		quaternion = quaternion.slerp(targetQuaternion, _delta * TAU)
	move_and_slide()
	pass
