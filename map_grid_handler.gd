extends Node
class_name GlobalGrid

static func ParseImage(image: Image, include_water: bool) -> AStarGrid2D:
	var grid = AStarGrid2D.new()
	grid.region = Rect2i(Vector2i.ZERO, image.get_size() * 0.5)
	grid.update()
	for i in range(grid.region.size.x): 
		for j in range(grid.region.size.y):
			var solid = false
			for dx in range(2):
				for dy in range(2):
					var c = image.get_pixel(i * 2 + dx, j * 2 + dy)
					if c.r > 0.5 or (include_water and c.b > 0.5):
						solid = true
						break
				if solid:
					break
			grid.set_point_solid(Vector2i(i,j),solid)
	return grid
	pass
	
static func AddHazard(grid: AStarGrid2D, position: Vector3, radius: float):
	var x = round(position.x)
	var y = round(position.z)
	var box_size = ceili(radius)
	var r2 = radius * radius
	
	for nx in range(x - box_size, x + box_size + 1):
		for ny in range(y - box_size, y + box_size + 1):
			if nx < 0 or ny < 0 or nx >= grid.size.x or ny >= grid.size.y:
				continue
			
			if Vector2(x - nx, y - ny).length_squared() > r2:
				continue
				
			grid.set_point_solid(Vector2(nx, ny), true)
			
static func RemoveWater(grid: AStarGrid2D, position: Vector3, radius: float, image: Image):
	var x = round(position.x)
	var y = round(position.z)
	var box_size = ceili(radius)
	var r2 = radius * radius
	
	for nx in range(x - box_size, x + box_size + 1):
		for ny in range(y - box_size, y + box_size + 1):
			if nx < 0 or ny < 0 or nx >= grid.size.x or ny >= grid.size.y:
				continue
			
			if Vector2(x - nx, y - ny).length_squared() > r2:
				continue
				
			var solid = false
			for dx in range(2):
				for dy in range(2):
					var c = image.get_pixel(ny * 2 + dx, ny * 2 + dy)
					if c.r > 0.5:
						solid = true
						break
				if solid:
					break
				
			grid.set_point_solid(Vector2(nx, ny), solid)
