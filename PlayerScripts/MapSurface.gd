extends ItemBase

@export var TargetMesh: MeshInstance3D
@export var Map: EditableMap
@export var Camera: Camera3D
@export var Collider: CollisionObject3D
@export var DrawSize: int = 5
@export var CliffColor: Color = Color.BLACK
@export var WaterColor: Color = Color.BLUE
@export var WaterToolButton: StaticBody3D
@export var CliffToolButton: StaticBody3D
@export var EraserToolButton: StaticBody3D
@export var ButtonDefaultScale = 0.18
@export var ButtonPressedScale = 0.25
@export var ToolParent: Node3D
@export var ToolModelParent: Node3D
@export var MarkerCliff: Node3D
@export var MarkerWater: Node3D
@export var Eraser: Node3D
@export var Scale: Node3D

var material: ShaderMaterial
var isPainting: bool
var lastPosition: Vector2
var highlightedButton: StaticBody3D
var currentButton: StaticBody3D
var currentToolModel: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Map.CreateImage()
	
	var aspect = Map.Width / float(Map.Height)
	TargetMesh.scale = Vector3(aspect, 1, 1)
	ToolParent.position = Vector3(aspect * -0.5 - 0.138, 0, 0)
	
	
	var scaleWidth = 25.0 / Map.Height
	Scale.scale = Vector3(scaleWidth, scaleWidth, 1)
	Scale.position = Vector3(aspect * -0.5, Scale.position.y, 0)
	
	material = TargetMesh.get_material_override()
	material.set_shader_parameter("Texture", Map.texture)
	material.set_shader_parameter("TextureSize", Vector2(Map.Width, Map.Height))
	TargetMesh.set_material_override(material)
	currentButton = CliffToolButton
	currentButton.scale = Vector3(ButtonPressedScale, ButtonPressedScale, ButtonPressedScale)
	
	ToolModelParent.remove_child(Eraser)
	ToolModelParent.remove_child(MarkerWater)
	ToolModelParent.remove_child(MarkerCliff)

func _enter_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _unhandled_input(event: InputEvent):
	var pressedThisFrame = false
	if event.is_action_pressed("draw"):
		if highlightedButton == Collider:
			isPainting = true
			pressedThisFrame = true
		elif highlightedButton:
			
			if currentButton and currentButton != highlightedButton:
				currentButton.scale = Vector3(ButtonDefaultScale, ButtonDefaultScale, ButtonDefaultScale)
			currentButton = highlightedButton
			
	if event.is_action_released("draw"):
		isPainting = false
			
	if event is InputEventMouse:
		var mouseEvent: InputEventMouse = event
		var origin = Camera.project_ray_origin(mouseEvent.position)
		var direction = Camera.project_ray_normal(mouseEvent.position)
		var query = PhysicsRayQueryParameters3D.create(origin, origin + direction * 500, 1 << 15)
		var spaceRid = get_world_3d().space
		var spaceState = PhysicsServer3D.space_get_direct_state(spaceRid)
		var result = spaceState.intersect_ray(query)
		if not result:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			if currentToolModel:
				ToolModelParent.remove_child(currentToolModel)
				currentToolModel = null
			return
			
		var newHighlightButton = null
		if result.collider == Collider:
			newHighlightButton = Collider
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			if !currentToolModel:
				if currentButton == CliffToolButton:
					currentToolModel = MarkerCliff
				elif currentButton == WaterToolButton:
					currentToolModel = MarkerWater
				elif currentButton == EraserToolButton:
					currentToolModel = Eraser
				
				if currentToolModel:
					ToolModelParent.add_child(currentToolModel)
			if currentToolModel:
				currentToolModel.global_position = result.position
			if isPainting:
				var localPoint = TargetMesh.to_local(result.position)
				var imagePoint = Vector2(localPoint.x, localPoint.y)
				imagePoint += Vector2(0.5, 0.5)
				imagePoint.y = 1.0 - imagePoint.y
				imagePoint.x *= Map.Width
				imagePoint.y *= Map.Height
				
				var color = CliffColor
				if currentButton == WaterToolButton:
					color = WaterColor
				if currentButton == EraserToolButton:
					color = Map.BGColor
				var delta = DrawSize * 0.25
				var offset = imagePoint - lastPosition
				if not pressedThisFrame and offset.length_squared() > delta * delta:
					var vDelta = offset.normalized() * delta
					var distance = offset.length()
					var pointCount = ceili(distance / delta)
					for i in range(pointCount):
						Map.Draw(lastPosition + vDelta * i, DrawSize, color, false)
				
				Map.Draw(imagePoint, DrawSize, color, true)
				
				lastPosition = imagePoint
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			if currentToolModel:
				ToolModelParent.remove_child(currentToolModel)
				currentToolModel = null
			
		if result.collider == CliffToolButton:
			newHighlightButton = CliffToolButton
		if result.collider == WaterToolButton:
			newHighlightButton = WaterToolButton
		if result.collider == EraserToolButton:
			newHighlightButton = EraserToolButton
			
		if newHighlightButton != highlightedButton:
			if highlightedButton and highlightedButton != currentButton and highlightedButton != Collider:
				highlightedButton.scale = Vector3(ButtonDefaultScale, ButtonDefaultScale, ButtonDefaultScale)
				
			highlightedButton = newHighlightButton
			
			if highlightedButton and highlightedButton != Collider:
				highlightedButton.scale = Vector3(ButtonPressedScale, ButtonPressedScale, ButtonPressedScale)
		
		
