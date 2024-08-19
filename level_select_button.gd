extends VBoxContainer

@export var display_name = "Level "

@onready var button: Button = $Button
@onready var stars: HBoxContainer = $Stars

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.text = display_name
	var dict = SaveStateManger.get_star_dict()
	if dict.has(name):
		for i in range(dict[name]):
			stars.get_child(i).visible = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(str("res://Scenes/Levels/",name.to_lower(),".tscn"))
	pass # Replace with function body.
