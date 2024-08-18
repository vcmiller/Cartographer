extends Node
class_name GlobalGrid

static func ParseImage(image: Image) -> AStarGrid2D:
	var grid = AStarGrid2D.new()
	grid.region = Rect2i(Vector2i.ZERO, image.get_size() * 0.5)
	grid.update()
	for i in range(grid.region.size.x): 
		for j in range(grid.region.size.y):
			var solid = false
			for dx in range(2):
				for dy in range(2):
					if image.get_pixel(i * 2 + dx, j * 2 + dy).r > 0.5:
						solid = true
						break
				if solid:
					break
			grid.set_point_solid(Vector2i(i,j),solid)
	return grid
	pass
