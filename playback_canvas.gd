extends CanvasLayer
class_name PlaybackCanvas

@onready var fuck_label: Label = $FuckLabel

func activate():
	show()
	fuck_label.hide()

func deactivate():
	hide()
