extends ItemBase
class_name MapItem

signal flag_marker_placed(index: int, position: Vector3)

@export var TargetMesh: MeshInstance3D
@export var Camera: Camera3D
@export var Collider: CollisionObject3D
@export var DrawSize: float = .05
@export var WaterToolButton: StaticBody3D
@export var CliffToolButton: StaticBody3D
@export var EraserToolButton: StaticBody3D
@export var MarkerButtons: Array[StaticBody3D]
@export var MarkerButtonMeshes: Array[MeshInstance3D]
@export var ButtonDefaultScale = 0.18
@export var ButtonPressedScale = 0.25
@export var ToolParent: Node3D
@export var FlagParent: Node3D
@export var ToolModelParent: Node3D
@export var MarkerCliff: Node3D
@export var MarkerWater: Node3D
@export var Eraser: Node3D
@export var MarkerItem: MeshInstance3D
@export var Scale: Node3D
@export var Player: PlayerController
@export var MarkerScene: PackedScene
@export var ExtraMarkerScene: PackedScene

@onready var drawing_sound: AudioStreamPlayer = $DrawingSound
@onready var erasing_sound: AudioStreamPlayer = $ErasingSound
@onready var compass_quad: Node3D = $Compass
@onready var draw_size_indicator: MeshInstance3D = $"3DTools/DrawSizeIndicator"
@onready var mouse_hint: Node3D = $MouseHint

var draw_size_mesh: TorusMesh;

var material: ShaderMaterial
var isPainting: bool
var lastPosition: Vector2
var highlightedButton: StaticBody3D
var currentButton: StaticBody3D
var currentToolModel: Node3D
var map: EditableMap
var draw_size_mul: int = 3

var extraMarkerPositions: Array[Vector3]
var extraMarkerSprites: Array[Texture2D]
var markerSprites: Array[Texture2D]
var markersLocked: Array[bool]
var currentPlacingMarker: int

var createdMarkers: Array[MeshInstance3D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	
	map = Player.Map
	map.CreateImageIfNecessary()
	
	var aspect = map.Width / float(map.Height)
	TargetMesh.scale = Vector3(aspect, 1, 1)
	ToolParent.position = Vector3(aspect * -0.5 - 0.138, 0, 0)
	FlagParent.position = Vector3(aspect * 0.5 + 0.138, 0, 0)
	compass_quad.position = Vector3(aspect * 0.5 - 0.1, -0.4, 0)
	mouse_hint.position = Vector3(aspect * 0.5, 0.5, 0)
	
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
	ToolModelParent.remove_child(MarkerItem)
	
	draw_size_mesh = draw_size_indicator.mesh as TorusMesh
	ToolModelParent.remove_child(draw_size_indicator)
	update_draw_size_indicator()
	
	for i in range(len(extraMarkerPositions)):
		var localPos = WorldToMapSpace(extraMarkerPositions[i])
		var newMarker = ExtraMarkerScene.instantiate() as MeshInstance3D
		var mat = StandardMaterial3D.new()
		mat.albedo_texture = extraMarkerSprites[i]
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
		newMarker.set_surface_override_material(0, mat)
		newMarker.position = localPos
		add_child(newMarker)
		
	for i in range(len(map.markerLocations)):
		var newMarker = MarkerScene.instantiate() as MeshInstance3D
		var mat = StandardMaterial3D.new()
		mat.albedo_texture = markerSprites[i]
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
		(newMarker.get_child(0) as MeshInstance3D).set_surface_override_material(0, mat)
		
		if map.markersPlaced[i]:
			var localPos = WorldToMapSpace(map.markerLocations[i])
			newMarker.position = localPos
		else:
			newMarker.hide()
		add_child(newMarker)
		createdMarkers.append(newMarker)
	
	for i in range(len(MarkerButtons)):
		if i < len(markerSprites) and not markersLocked[i]:
			var mat = StandardMaterial3D.new()
			mat.albedo_texture = markerSprites[i]
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			MarkerButtonMeshes[i].set_surface_override_material(0, mat)
		else:
			MarkerButtons[i].get_parent().remove_child(MarkerButtons[i])
		
func WorldToMapSpace(worldPos: Vector3) -> Vector3:
	var aspect = map.Width / float(map.Height)
	var local = Vector3(worldPos.x, worldPos.z, 0)
	local /= (map.Height * 0.5)
	local.y = 1 - local.y
	local -= Vector3(0.5 * aspect, 0.5, 0)
	return local
	
func MapToWorldSpace(mapPos: Vector3) -> Vector3:
	var aspect = map.Width / float(map.Height)
	var world = Vector3(mapPos.x, 0, mapPos.y)
	world += Vector3(0.5 * aspect, 0, 0.5)
	world.z = 1 - world.z
	world *= (map.Height * 0.5)
	return world

func _enter_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update_draw_size_indicator():
	var radius = DrawSize * draw_size_mul * 0.5
	draw_size_mesh.inner_radius = radius - .002
	draw_size_mesh.outer_radius = radius + .002
	
func _unhandled_input(event: InputEvent):
	var pressedThisFrame = false
	if event.is_action_pressed("draw"):
		if highlightedButton == Collider:
			isPainting = true
			pressedThisFrame = true
			if [MarkerCliff,MarkerWater].has(currentToolModel):
				drawing_sound.play()
			elif Eraser == currentToolModel:
				erasing_sound.play()
		elif highlightedButton:
			
			if currentButton and currentButton != highlightedButton:
				currentButton.scale = Vector3(ButtonDefaultScale, ButtonDefaultScale, ButtonDefaultScale)
			currentButton = highlightedButton
			
	if event.is_action_released("draw"):
		isPainting = false
		drawing_sound.stop()
		erasing_sound.stop()
		
	if event.is_action_pressed("toggle_size"):
		draw_size_mul = 4 - draw_size_mul
		update_draw_size_indicator()
			
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
			if draw_size_indicator.get_parent() == ToolModelParent:
				ToolModelParent.remove_child(draw_size_indicator)
				
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
						
				if currentToolModel:
					ToolModelParent.add_child(draw_size_indicator)
				
				var markerIndex = MarkerButtons.find(currentButton)
				if markerIndex >= 0:
					currentToolModel = MarkerItem
					(MarkerItem.get_child(0) as MeshInstance3D).set_surface_override_material(0, MarkerButtonMeshes[markerIndex].get_surface_override_material(0))
					currentPlacingMarker = markerIndex
				
				if currentToolModel:
					ToolModelParent.add_child(currentToolModel)
			if currentToolModel:
				currentToolModel.global_position = result.position
				if draw_size_indicator.get_parent():
					draw_size_indicator.global_position = result.position
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
					
				var drawSize = ceili(map.Height * DrawSize * draw_size_mul)
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
				var mapPos = currentToolModel.position
				var worldPos = MapToWorldSpace(mapPos)
				
				map.markersPlaced[currentPlacingMarker] = true
				map.markerLocations[currentPlacingMarker] = worldPos
				createdMarkers[currentPlacingMarker].show()
				createdMarkers[currentPlacingMarker].position = mapPos
				flag_marker_placed.emit(currentPlacingMarker, worldPos)
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			if currentToolModel:
				ToolModelParent.remove_child(currentToolModel)
				currentToolModel = null
			if draw_size_indicator.get_parent() == ToolModelParent:
				ToolModelParent.remove_child(draw_size_indicator)
			
		if [CliffToolButton,WaterToolButton,EraserToolButton].has(result.collider) or MarkerButtons.has(result.collider):
			newHighlightButton = result.collider
			
		if newHighlightButton != highlightedButton:
			if highlightedButton and highlightedButton != currentButton and highlightedButton != Collider:
				highlightedButton.scale = Vector3(ButtonDefaultScale, ButtonDefaultScale, ButtonDefaultScale)
				
			highlightedButton = newHighlightButton
			
			if highlightedButton and highlightedButton != Collider:
				highlightedButton.scale = Vector3(ButtonPressedScale, ButtonPressedScale, ButtonPressedScale)
		
		
