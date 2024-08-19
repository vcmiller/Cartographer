extends PopupPanel

signal bgm_slider_value_changed(value)
signal amb_slider_value_changed(value)
signal sfx_slider_value_changed(value)

@export var bgm_volume = 50
@export var amb_volume= 50
@export var sfx_volume= 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bgm_slider_value_changed(value: float) -> void:
	bgm_volume= value
	bgm_slider_value_changed.emit(value)
	pass # Replace with function body.


func _on_ambience_slider_value_changed(value: float) -> void:
	amb_volume = value
	amb_slider_value_changed.emit(value)
	pass # Replace with function body.


func _on_sfx_slider_value_changed(value: float) -> void:
	sfx_volume = value
	sfx_slider_value_changed.emit(value)
	pass # Replace with function body.
