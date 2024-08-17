extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var CameraNode: Camera3D
@export var LookLimit: float = 80
@export var MouseSensitivity: float = 0.5

var lastMousePos: Vector2
var hasLastMouseEvent: bool
var eulerAngles: Vector3

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	eulerAngles = CameraNode.rotation

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if hasLastMouseEvent:
			var delta = (event.position - lastMousePos) * MouseSensitivity * -PI / 180
			eulerAngles.x = clamp(eulerAngles.x + delta.y, -LookLimit, LookLimit)
			eulerAngles.y += delta.x
			CameraNode.rotation = eulerAngles
		
		lastMousePos = event.position
		hasLastMouseEvent = true
	


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_l", "move_r", "move_f", "move_b")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
