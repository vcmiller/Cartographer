extends AudioStreamPlayer

@export var sounds: Array[AudioStream]

func play_random() -> void:
	stream = sounds.pick_random()
	play()
	pass # Replace with function body.
