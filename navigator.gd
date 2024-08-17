extends Node3D
 
@export var tex: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tex_img = tex.get_image()
	MapGridHandler.ParseImage(tex_img)
	var img = Image.create_empty(tex_img.get_size().x,tex_img.get_size().y, false, Image.FORMAT_RGB8)
	draw_path(img,Vector2i.ZERO,Vector2i(127,127), Color.RED)
	draw_path(img,Vector2i(127,0),Vector2i(0,127), Color.BLUE)
	draw_path(img,Vector2i(0,90),Vector2i(127,90), Color.GREEN)
	%DBTex.texture = ImageTexture.create_from_image(img)
	pass # Replace with function body.

func draw_path(img: Image, from: Vector2i, to: Vector2i, color: Color):
	var path = MapGridHandler.grid.get_point_path(from,to)
	for node in path: img.set_pixelv(node, color)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(position)
	pass
