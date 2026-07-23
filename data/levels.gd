extends Node
class_name Levels

var ref = Enemies

static var all = [
	wave(10, [c("Bee", 3), c("Bee", 3), c("Bee", 3)]),
	wave(15, [c("Bee", 40)]),
	wave(50, [c("Goblin", 5), c("Goblin King", 1, 1), c("Kobold", 5)]),
	wave(10, [c("Goblin Tank", 1)]),
	wave(100, [c("Goblin Queen", 1)]),
]

static var waypoints = [Vector2i(32, 32)]

static func wave(wave_bounty, creeps):
	return {
		"bounty": wave_bounty,
		"creeps": creeps,
	}
static func c(enemyName, amount, interval = 0.3):
	return {
		"unit": enemyName,
		"amount": amount,
		"spawnInterval": interval,
	}

static func generate_obstacles(
		width: int,
		height: int,
		fill_percent := 0.4,
		smoothing_iterations := 5,
		seed := randi()
	) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	
	var grid_width = width * 2 + 1
	var grid_height = height * 2 + 1
	
	var grid := []

	# Initial random fill
	for x in grid_width:
		grid.append([])
		for y in grid_height:
			grid[x].append(rng.randf() < fill_percent)

	# Keep border empty
	for x in grid_width:
		grid[x][0] = false
		grid[x][height - 1] = false

	for y in grid_height:
		grid[0][y] = false
		grid[width - 1][y] = false

	# Smooth several times
	for i in smoothing_iterations:
		grid = smooth_grid(grid)

	# Convert to your map format
	var map: Array[Vector2i] = []

	for gx in grid_width:
		for gy in grid_height:
			if grid[gx][gy]:
				var world_x = gx - width
				var world_y = gy - height

				# Don't place near spawn
				if abs(world_x) <= 1 and abs(world_y) <= 1:
					continue
					
				map.append(Vector2i(world_x, world_y))

	return map

static func smooth_grid(grid: Array) -> Array:
	var width = grid.size()
	var height = grid[0].size()

	var new_grid := []

	for x in width:
		new_grid.append([])

		for y in height:
			var neighbours = count_neighbours(grid, x, y)

			if neighbours > 4:
				new_grid[x].append(true)
			elif neighbours < 4:
				new_grid[x].append(false)
			else:
				new_grid[x].append(grid[x][y])
				
	return new_grid
	
static func count_neighbours(grid, cx, cy):
	var count := 0

	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0:
				continue

			var x = cx + dx
			var y = cy + dy

			if x < 0 or y < 0 or x >= grid.size() or y >= grid[0].size():
				continue

			if grid[x][y]:
				count += 1

	return count
