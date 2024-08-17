extends ItemBase
class_name MapItem

@export var TargetMesh: MeshInstance3D
@export var Camera: Camera3D
@export var Collider: CollisionObject3D
@export var DrawSize: float = .05
@export var WaterToolButton: StaticBody3D
@export var CliffToolButton: StaticBody3D
@export var EraserToolButton: StaticBody3D
@export var RedFlagButton: StaticBody3D
@export var BlueFlagButton: StaticBody3D
@export var GreenFlagButton: StaticBody3D
@export var ButtonDefaultScale = 0.18
@export var ButtonPressedScale = 0.25
@export var ToolParent: Node3D
@export var FlagParent: Node3D
@export var ToolModelParent: Node3D
@export var MarkerCliff: Node3D
@export var MarkerWater: Node3D
@export var Eraser: Node3D
@export var RedFlag: Node3D
@export var BlueFlag: Node3D
@export var GreenFlag: Node3D
@export var RedFlagMarker: Node3D
@export var BlueFlagMarker: Node3D
@export var GreenFlagMarker: Node3D
@export var Scale: Node3D
@export var Player: PlayerController

var material: ShaderMaterial
var isPainting: bool
var lastPosition: Vector2
var highlightedButton: StaticBody3D
var currentButton: StaticBody3D
var currentToolModel: Node3D
var map: EditableMap

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	
	map = Player.Map
	map.CreateImageIfNecessary()
	
	var aspect = map.Width / float(map.Height)
	TargetMesh.scale = Vector3(aspect, 1, 1)
	ToolParent.position = Vector3(aspect * -0.5 - 0.138, 0, 0)
	FlagParent.position = Vector3(aspect * 0.5 + 0.138, 0, 0)
	
	
	var scaleWidth = 20.0 / map.Height
	Scale.scale = Vector3(scaleWidth, scaleWidth, 1)
	Scale.position = Vector3(aspect * -0.5, Scale.position.y, 0)
	
	material = TargetMesh.get_material_override()
	material.set_shader_parameter("Texture", map.texture)
	material.set_shader_parameter("TextureSize", Vector2(map.Width, map.Height))
	TargetMesh.set_material_override(material)
	currentButton = CliffToolButton
	currentButton.scale = Vector3(ButtonPressedScale, ButtonPressedScale, ButtonPressedScale)
	
	ToolModelParent.remove_child(Eraser)
	ToolModelParent.remove_child(MarkerWater)
	ToolModelParent.remove_child(MarkerCliff)
	ToolModelParent.remove_child(RedFlag)
	ToolModelParent.remove_child(BlueFlag)
	ToolModelParent.remove_child(GreenFlag)

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
				match(currentButton):
					CliffToolButton:
						currentToolModel = MarkerCliff
					WaterToolButton:
						currentToolModel = MarkerWater
					EraserToolButton:
						currentToolModel = Eraser
					RedFlagButton:
						currentToolModel = RedFlag	
					BlueFlagButton:
						currentToolModel = BlueFlag	
					GreenFlagButton:
						currentToolModel = GreenFlag	
				
				if currentToolModel:
					ToolModelParent.add_child(currentToolModel)
			if currentToolModel:
				currentToolModel.global_position = result.position
			if isPainting and [MarkerCliff,MarkerWater,Eraser].has(currentToolModel):
				var localPoint = TargetMesh.to_local(result.position)
				var imagePoint = Vector2(localPoint.x, localPoint.y)
				imagePoint += Vector2(0.5, 0.5)
				imagePoint.y = 1.0 - imagePoint.y
				imagePoint.x *= map.Width
				imagePoint.y *= map.Height
				
				var color = Color.RED
				if currentButton == WaterToolButton:
					color = Color.BLUE
				if currentButton == EraserToolButton:
					color = Color.BLACK
					
				var drawSize = ceili(map.Height * DrawSize)
				var delta = drawSize * 0.25
				var offset = imagePoint - lastPosition
				if not pressedThisFrame and offset.length_squared() > delta * delta:
					var vDelta = offset.normalized() * delta
					var distance = offset.length()
					var pointCount = ceili(distance / delta)
					for i in range(pointCount):
						map.Draw(lastPosition + vDelta * i, drawSize, color, false)
				
				map.Draw(imagePoint, drawSize, color, true)
				
				lastPosition = imagePoint
			elif isPainting:
				match(currentToolModel):
					RedFlag:
						RedFlagMarker.position=  currentToolModel.position
					BlueFlag:
						BlueFlagMarker.position=  currentToolModel.position
					GreenFlag:
						GreenFlagMarker.position=  currentToolModel.position
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			if currentToolModel:
				ToolModelParent.remove_child(currentToolModel)
				currentToolModel = null
			
		if [CliffToolButton,WaterToolButton,EraserToolButton,RedFlagButton,BlueFlagButton,GreenFlagButton].has(result.collider):
			newHighlightButton = result.collider
			
		if newHighlightButton != highlightedButton:
			if highlightedButton and highlightedButton != currentButton and highlightedButton != Collider:
				highlightedButton.scale = Vector3(ButtonDefaultScale, ButtonDefaultScale, ButtonDefaultScale)
				
			highlightedButton = newHighlightButton
			
			if highlightedButton and highlightedButton != Collider:
				highlightedButton.scale = Vector3(ButtonPressedScale, ButtonPressedScale, ButtonPressedScale)
		
		
