extends CanvasLayer
class_name PlayerCanvas

@onready var item_select: HBoxContainer = $ItemSelect
@onready var map_container: PanelContainer = $ItemSelect/MapContainer
@onready var compass_container: PanelContainer = $ItemSelect/CompassContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	on_selected_item_changed(0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_selected_item_changed(item: int): 
	var tween = create_tween()
	for index in range(item_select.get_child_count()) :
		var item_obj: PanelContainer = item_select.get_child(index)
		var color = Color.DIM_GRAY
		if index == item: color = Color.WHITE
		tween.parallel().tween_property(item_obj,"self_modulate",color,0.21).set_trans(Tween.TRANS_QUART)
	tween.play()
