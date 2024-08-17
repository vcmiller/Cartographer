extends ItemBase

@export var HundredsDigit: Node3D
@export var TensDigit: Node3D
@export var OnesDigit: Node3D
@export var Player: PlayerController

var startDist: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("draw"):
		var tween = create_tween()
		tween.tween_property(self,"startDist",Player.distanceWalked, 0.2)
		tween.play()
		#startDist = Player.distanceWalked

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var total = Player.distanceWalked - startDist

	var fractional = fmod(total, 1)	
	var onesPercent = fmod(floor(total), 10) / 10.0
	if fractional > 0.7:
		onesPercent += (fractional - 0.7) / 3.0
	
	var tensPercent = fmod(floor(total / 10), 10) / 10.0
	if onesPercent > 0.9:
		tensPercent += onesPercent - 0.9
		
	var hundredsPercent = fmod(floor(total / 100), 10) / 10.0
	if tensPercent > 0.9:
		hundredsPercent += tensPercent - 0.9
		
	OnesDigit.rotation = Vector3(onesPercent * TAU, 0, 0)
	TensDigit.rotation = Vector3(tensPercent * TAU, 0, 0)
	HundredsDigit.rotation = Vector3(hundredsPercent * TAU, 0, 0)
