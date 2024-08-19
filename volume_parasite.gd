extends Node

enum VOL_TYPE {BGM,AMBIENCE,SFX}

@export var volume_type = VOL_TYPE.BGM
@onready var audio_player = (get_parent() as AudioStreamPlayer)
var initial_vol = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_vol = audio_player.volume_db
	match(volume_type):
		VOL_TYPE.BGM:
			SettingsPopup.bgm_slider_value_changed.connect(update_volume)
		VOL_TYPE.AMBIENCE:
			SettingsPopup.amb_slider_value_changed.connect(update_volume)
		VOL_TYPE.SFX:
			SettingsPopup.sfx_slider_value_changed.connect(update_volume)
	update_volume(50)

func update_volume(value):
	audio_player.volume_db = linear_to_db(db_to_linear(initial_vol) * value/100) 
