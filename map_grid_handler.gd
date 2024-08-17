extends Node
class_name GlobalGrid

var grid: AStarGrid2D

func ParseImage(image: Image):
	grid = AStarGrid2D.new()
	grid.region = Rect2i(Vector2i.ZERO,image.get_size())
	grid.update()
	for i in range(grid.region.size.x): 
		for j in range(grid.region.size.y):
			var solid = image.get_pixel(i,j).r > 0.5
			grid.set_point_solid(Vector2i(i,j),solid)
	pass
