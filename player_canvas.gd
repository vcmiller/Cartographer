extends CanvasLayer
class_name PlayerCanvas

@onready var item_select: HBoxContainer = $ItemSelect
@onready var map_container: PanelContainer = $ItemSelect/MapContainer
@onready var compass_container: PanelContainer = $ItemSelect/CompassContainer
@onready var info_screen: Control = $InfoScreen
@onready var portrait_box: TextureRect = $InfoScreen/Panel/VBoxContainer/Title/TextureRect
@onready var title_label: Label = $InfoScreen/Panel/VBoxContainer/Title/Label
@onready var paragraph_label: RichTextLabel =  $InfoScreen/Panel/VBoxContainer/MarginContainer/RichTextLabel
@onready var move_controls: Control = $MoveControls
@onready var item_controls: Control = $ItemControls
@onready var counter_item_control: Control = $ItemControls/MarginContainer/VBoxContainer/WalkerItemControl

@export var button_parent: Control
@export var show_move_controls: bool
@export_range(1,3) var num_items_shown: int = 3

var player: PlayerController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	on_selected_item_changed(0)
	move_controls.visible = show_move_controls
	while item_select.get_child_count() > num_items_shown: 
		var child = item_select.get_child(num_items_shown) 
		item_select.remove_child(child)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).keycode == KEY_ESCAPE and info_screen.visible:
		hide_info()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player and player.item_manager and player.item_manager.currentItem is MapItem:
		button_parent.show()
		item_controls.hide()
		if show_move_controls: move_controls.hide()
	else:
		button_parent.hide()
		item_controls.show()
		if show_move_controls: move_controls.show()
		
	if info_screen.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func on_selected_item_changed(item: int): 
	var tween = create_tween()
	for index in range(item_select.get_child_count()) :
		var item_obj: PanelContainer = item_select.get_child(index)
		var color = Color.DIM_GRAY
		if index == item: color = Color.WHITE
		tween.parallel().tween_property(item_obj,"self_modulate",color,0.21).set_trans(Tween.TRANS_QUART)
	tween.play()
	counter_item_control.visible = item == 2
	
func show_last_info():
	info_screen.show()
	SettingsPopup.enabled = false
	
func show_info(portrait: Texture2D, title: String, paragraph: String, show: bool):
	if show:
		info_screen.show()
		SettingsPopup.enabled = false
	else:
		info_screen.hide()
	
	portrait_box.texture = portrait
	title_label.text = title
	paragraph_label.text = paragraph
	
func hide_info():
	info_screen.hide()
	await get_tree().create_timer(0.1).timeout
	SettingsPopup.enabled = true
	
	
func submit_map():
	player.submit()
	
func close_map():
	var tree = get_tree()
	player.item_manager.SetItem(null)
