extends Node3D

@export var TargetMesh: MeshInstance3D
@export var Map: EditableMap
@export var Camera: Camera3D
@export var Collider: CollisionObject3D
@export var DrawSize: int = 5
@export var DrawColor: Color = Color.BLACK

var material: Material
var isPainting: bool
var lastPosition: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Map.CreateImage()
	
	material = StandardMaterial3D.new()
	material.albedo_texture = Map.texture
	TargetMesh.set_surface_override_material(0, material)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _unhandled_input(event: InputEvent):
	var pressedThisFrame = false
	if event is InputEventMouseButton:
		if event.is_pressed():
			isPainting = true
			pressedThisFrame = true
			
		elif event.is_released():
			isPainting = false
			
	if event is InputEventMouse and isPainting:
		var mouseEvent: InputEventMouse = event
		var origin = Camera.project_ray_origin(mouseEvent.position)
		var direction = Camera.project_ray_normal(mouseEvent.position)
		var query = PhysicsRayQueryParameters3D.create(origin, origin + direction * 500)
		var spaceRid = get_world_3d().space
		var spaceState = PhysicsServer3D.space_get_direct_state(spaceRid)
		var result = spaceState.intersect_ray(query)
		if result and result.collider == Collider:
			var localPoint = TargetMesh.to_local(result.position)
			var imagePoint = Vector2(localPoint.x, localPoint.y)
			imagePoint += Vector2(0.5, 0.5)
			imagePoint.y = 1.0 - imagePoint.y
			imagePoint.x *= Map.Width
			imagePoint.y *= Map.Height
			
			var delta = DrawSize * 0.25
			var offset = imagePoint - lastPosition
			if not pressedThisFrame and offset.length_squared() > delta * delta:
				var vDelta = offset.normalized() * delta
				var distance = offset.length()
				var pointCount = ceili(distance / delta)
				for i in range(pointCount):
					Map.Draw(lastPosition + vDelta * i, DrawSize, DrawColor, false)
			
			Map.Draw(imagePoint, DrawSize, DrawColor, true)
			
			lastPosition = imagePoint
		
		
