extends Resource
class_name EditableMap

@export var Width: int
@export var Height: int

var image: Image
var texture: ImageTexture

func CreateImage():
	image = Image.create(Width, Height, false, Image.FORMAT_RGBA8)
	image.fill(Color.BLACK)
	
	texture = ImageTexture.create_from_image(image)
		
func Draw(position: Vector2, size: int, color: Color, update: bool):
	var x = roundi(position.x)
	var y = roundi(position.y)
	
	var radius = size / 2.0
	var min = floori(radius)
	var max = ceili(radius)
	for i in range(x - min, x + max):
		for j in range (y - min, y + max):
			if i < 0 or j < 0 or i >= Width or j >= Height:
				continue
			var offset = Vector2(i - x, j - y)
			if (offset.length_squared() > radius * radius):
				continue
			image.set_pixel(i, j, color)
	
	if update:
		UpdateImage()
	
func UpdateImage():
	texture.update(image)
