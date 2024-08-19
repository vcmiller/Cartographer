extends CharacterBody3D
class_name Navigator

@export var Model: Node3D
@export var remote: RemoteTransform3D
@export var anim: AnimationPlayer
@export var cameraArm: Node3D
@export var thoughtBubble: Node3D
@export var thoughtBubbleIcon: MeshInstance3D
@export var thoughtBubbleNoDest: Node3D
@export var thoughtBubbleNoPath: Node3D
@export var body: MeshInstance3D
@export var hairs: Array[MeshInstance3D]
@export var facialHairs: Array[MeshInstance3D]
@export var skinColors: Array[Color]
@export var hairColors: Array[Color]
@export var eyeColors: Array[Color]
@export var clothesColors: Array[Color]
@export var hairChance: float = 0.8
@export var facialHairChance: float = 0.3
@export var bodyAttach: Node3D

@onready var lineDrawer: MeshInstance3D = $LineDrawer

const SPEED = 15
const MOVE_DELAY = 1

var elapsed: float
var grid: AStarGrid2D
var map: EditableMap
var destIndex: int
var goal: Goal
var level_controller: LevelController
var is_dead = false

func _ready() -> void:
	anim.play("Walk")
	cameraArm.rotation = Vector3(0, PI, 0)
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = goal.marker_sprite
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	thoughtBubbleIcon.set_surface_override_material(0, mat)
	randomize_mesh()
	
	level_controller.connect("update_map", _on_update_map)
	
func create_grid(map: EditableMap):
	self.map = map
	grid = MapGridHandler.ParseImage(map.image)
	for i in range(len(level_controller.goals)):
		var goal = level_controller.goals[i]
		if goal == self.goal or not goal.is_hazard or not map.markersPlaced[i] or goal.is_dead: continue
		MapGridHandler.AddHazard(grid, map.markerLocations[i], goal.hazard_radius)
		
func _on_update_map():
	if not goal.is_dead:
		create_grid(map)
	
func check_goal(hit_goal: Goal):
	if hit_goal.is_dead: return
	if hit_goal == goal:
		hit_goal.die()
		level_controller.succccess()
	elif hit_goal.is_hazard:
		level_controller.fail()
		is_dead = true
		anim.play("Die")

#debug nonsense: ignore
func draw_path(img: Image, from: Vector2i, to: Vector2i, color: Color):
	var path = grid.get_point_path(from,to)
	for node in path: img.set_pixelv(node, color)
	
func randomize_mesh():
	var rng = RandomNumberGenerator.new()
	var skinColor = skinColors[rng.randi_range(0, len(skinColors) - 1)]
	var hairColor = hairColors[rng.randi_range(0, len(hairColors) - 1)]
	var eyeColor = eyeColors[rng.randi_range(0, len(eyeColors) - 1)]
	var shirtColor = clothesColors[rng.randi_range(0, len(clothesColors) - 1)]
	var pantsColor = clothesColors[rng.randi_range(0, len(clothesColors) - 1)]
	
	var bodySkinMat = body.mesh.surface_get_material(0).duplicate() as StandardMaterial3D
	bodySkinMat.albedo_color = skinColor
	body.set_surface_override_material(0, bodySkinMat)
	body.set_surface_override_material(8, bodySkinMat)
	
	var bodyHairMat = body.mesh.surface_get_material(7).duplicate() as StandardMaterial3D
	bodyHairMat.albedo_color = hairColor
	body.set_surface_override_material(7, bodyHairMat)
	
	var bodyEyeMat = body.mesh.surface_get_material(6).duplicate() as StandardMaterial3D
	bodyEyeMat.albedo_color = eyeColor
	body.set_surface_override_material(6, bodyEyeMat)
	
	var shirtMat = body.mesh.surface_get_material(1).duplicate() as StandardMaterial3D
	shirtMat.albedo_color = shirtColor
	body.set_surface_override_material(1, shirtMat)
	
	var pantsMat = body.mesh.surface_get_material(2).duplicate() as StandardMaterial3D
	pantsMat.albedo_color = pantsColor
	body.set_surface_override_material(2, pantsMat)
	
	if rng.randf() < hairChance:
		var hair = hairs[rng.randi_range(0, len(hairs) - 1)]
		var hairMat = hair.mesh.surface_get_material(0).duplicate() as StandardMaterial3D
		hairMat.albedo_color = hairColor
		hair.set_surface_override_material(0, hairMat)
		hair.show()
		var transform = hair.global_transform
		Model.remove_child(hair)
		bodyAttach.add_child(hair)
		hair.global_transform = transform
		
	if rng.randf() < facialHairChance:
		var facialHair = facialHairs[rng.randi_range(0, len(facialHairs) - 1)]
		var facialHairMat = facialHair.mesh.surface_get_material(0).duplicate() as StandardMaterial3D
		facialHairMat.albedo_color = hairColor
		facialHair.set_surface_override_material(0, facialHairMat)
		facialHair.show()
		var transform = facialHair.global_transform
		Model.remove_child(facialHair)
		bodyAttach.add_child(facialHair)
		facialHair.global_transform = transform
	
func vec2i(from: Vector3): return Vector2i(roundi(from.x), roundi(from.z))	
func vec3(from: Vector2i): return Vector3(from.x,position.y,from.y)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:  
	if !map.markersPlaced[destIndex]: return
	thoughtBubbleNoDest.hide()
	elapsed += _delta
	
	if elapsed < MOVE_DELAY or is_dead or not goal.get_parent():
		return
		
	
	var dest2d = vec2i(map.markerLocations[destIndex])
	var path = grid.get_point_path(vec2i(position), dest2d, true)
	
	var target_pos := position
	if len(path) < 2:
		thoughtBubble.show()
		thoughtBubbleNoPath.show()
		thoughtBubbleIcon.hide()
		return
	else:
		var lastPos = path[-1]
		if lastPos.distance_to(dest2d) > 2:
			thoughtBubble.show()
			thoughtBubbleNoPath.show()
			thoughtBubbleIcon.hide()
			return
		
		thoughtBubble.hide()
		var mesh : ImmediateMesh = lineDrawer.mesh
		mesh.clear_surfaces()
		mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
		
		for i in range(len(path)):
			mesh.surface_add_vertex(vec3(path[i]))
		
		mesh.surface_end()
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
		targetQuaternion = quaternion.inverse() * targetQuaternion
		Model.quaternion = Model.quaternion.slerp(targetQuaternion, _delta * TAU * 4)
		
		var camAngleDiff = cameraArm.quaternion.angle_to(targetQuaternion)
		if camAngleDiff > 0.01:
			var amtToRotate = min(camAngleDiff / 2, _delta * PI)
			var interp = amtToRotate / camAngleDiff
			cameraArm.quaternion = cameraArm.quaternion.slerp(targetQuaternion, interp)
	move_and_slide()
	pass
