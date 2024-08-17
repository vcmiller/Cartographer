extends CanvasLayer

@onready var map_container: PanelContainer = $ItemSelect/MapContainer
@onready var compass_container: PanelContainer = $ItemSelect/CompassContainer

@onready var _selected_item: ITEM_TYPE = ITEM_TYPE.NONE
enum ITEM_TYPE {NONE, MAP, COMPASS}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
