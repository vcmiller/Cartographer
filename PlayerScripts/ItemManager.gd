extends Node3D
class_name ItemManager

signal selected_item_changed(item_index)

@export var Items: Array[ItemBase]
@export var startItem: int = 0

var currentItem : ItemBase
var lastItem : ItemBase

func _ready() -> void:
	for item in Items:
		remove_child(item)
	if startItem >= 0:
		SetItem(Items[startItem])

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("next_item"):
		CycleWeapon(1)
	elif event.is_action_pressed("prev_item"):
		CycleWeapon(-1)
	elif event.is_action_pressed("unequip"):
		if currentItem:
			SetItem(null)
		elif lastItem:
			SetItem(lastItem)
	else:
		for i in range(len(Items)):
			if event.is_action_pressed("item_" + str(i)):
				SetItem(Items[i])
				
func CycleWeapon(change: int) -> void:
	var curIndex = Items.find(currentItem)
	curIndex = (((curIndex + change) % len(Items)) + len(Items)) % len(Items) 
	
	SetItem(Items[curIndex])
				
func SetItem(item: ItemBase) -> void:
	if item == currentItem:
		return
	
	if currentItem:
		remove_child(currentItem)
	
	lastItem = currentItem
	currentItem = item
	
	if currentItem:
		add_child(currentItem)
		selected_item_changed.emit(Items.find(item))
