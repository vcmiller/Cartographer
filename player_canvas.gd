extends CanvasLayer
class_name PlayerCanvas

@onready var item_select: HBoxContainer = $ItemSelect
@onready var map_container: PanelContainer = $ItemSelect/MapContainer
@onready var compass_container: PanelContainer = $ItemSelect/CompassContainer

@export var submit_button: Button
@export var close_map_button: Button
@export_range(1,3) var num_items_shown: int = 3

var player: PlayerController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	on_selected_item_changed(0)
	while item_select.get_child_count() > num_items_shown: 
		var child = item_select.get_child(num_items_shown) 
		item_select.remove_child(child)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.item_manager.currentItem is MapItem:
		submit_button.show()
		close_map_button.show()
	else:
		submit_button.hide()
		close_map_button.hide()

func on_selected_item_changed(item: int): 
	var tween = create_tween()
	for index in range(item_select.get_child_count()) :
		var item_obj: PanelContainer = item_select.get_child(index)
		var color = Color.DIM_GRAY
		if index == item: color = Color.WHITE
		tween.parallel().tween_property(item_obj,"self_modulate",color,0.21).set_trans(Tween.TRANS_QUART)
	tween.play()
	
func submit_map():
	player.submit()
	
func close_map():
	player.item_manager.SetItem(null)
