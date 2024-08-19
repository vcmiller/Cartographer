extends Camera3D

@export var noise_tex: Noise

@onready var initial_rotation: Vector3 = rotation
const rotation_speed=0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var time = Time.get_ticks_msec() / 1000.0
	rotation = initial_rotation
	rotate_x(noise_tex.get_noise_1d(time)*rotation_speed)
	rotate_y(noise_tex.get_noise_2d(1,time)*rotation_speed)
	pass
