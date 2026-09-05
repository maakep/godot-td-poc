class_name ObstaclePainter
extends RefCounted

## Atlas coordinates are separate from the generated map's blocked-cell mask.
const SOURCE_ID := 2
const WATER_ORIGIN := Vector2i(0, 1)
const FOREST_ORIGIN := Vector2i(0, 4)
const ROCK_TILES := [Vector2i(3, 1), Vector2i(4, 1)]
const TREE_TILE := Vector2i(3, 2)
const WAYPOINT_TILES := [Vector2i(0, 7), Vector2i(1, 7), Vector2i(2, 7)]
const NEIGHBORS := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]


static func paint(
		tilemap: TileMapLayer, cells: Array, seed_value: int, forest_chance := 0.5
	) -> void:
	var paintable: Array[Vector2i] = []

	for cell: Vector2i in cells:
		var tile := tilemap.get_cell_tile_data(cell)

		if tile != null and tile.get_custom_data("Waypoint"):
			continue

		paintable.append(cell)

	var layout := build_layout(paintable, seed_value, forest_chance)

	for cell: Vector2i in layout:
		tilemap.set_cell(cell, SOURCE_ID, layout[cell])


static func build_layout(
		cells: Array, seed_value: int, forest_chance := 0.5
	) -> Dictionary[Vector2i, Vector2i]:
	var rng := RandomNumberGenerator.new()
	var unseen: Dictionary[Vector2i, bool] = {}
	var layout: Dictionary[Vector2i, Vector2i] = {}

	rng.seed = seed_value

	for cell: Vector2i in cells:
		unseen[cell] = true

	var ordered := unseen.keys()

	ordered.sort_custom(_cell_before)

	for cell: Vector2i in ordered:
		if not unseen.has(cell):
			continue

		var component := _take_component(cell, unseen)

		# Pick once per connected obstacle group so the landscape stays coherent.
		var is_forest := rng.randf() < forest_chance

		_paint_component(component, is_forest, rng, layout)

	return layout


static func _take_component(
		start: Vector2i, unseen: Dictionary[Vector2i, bool]
	) -> Array[Vector2i]:
	var pending: Array[Vector2i] = [start]
	var component: Array[Vector2i] = []

	unseen.erase(start)

	while not pending.is_empty():
		var cell: Vector2i = pending.pop_back()

		component.append(cell)

		for direction: Vector2i in NEIGHBORS:
			var neighbor := cell + direction

			if unseen.erase(neighbor):
				pending.append(neighbor)

	component.sort_custom(_cell_before)
	return component


static func _paint_component(
		cells: Array[Vector2i], is_forest: bool, rng: RandomNumberGenerator,
		layout: Dictionary[Vector2i, Vector2i]
	) -> void:
	var available: Dictionary[Vector2i, bool] = {}
	var candidates: Array[Rect2i] = []
	var origin := FOREST_ORIGIN if is_forest else WATER_ORIGIN

	for cell in cells:
		available[cell] = true

	for cell in cells:
		var patch := _largest_patch_at(cell, available)

		if patch.has_area():
			candidates.append(patch)

	candidates.sort_custom(func(a: Rect2i, b: Rect2i) -> bool:
		if a.get_area() == b.get_area():
			return _cell_before(a.position, b.position)

		return a.get_area() > b.get_area()
	)

	for candidate in candidates:
		# Earlier, larger patches may have consumed part of this candidate.
		var patch := _largest_patch_at(candidate.position, available)

		for y in range(patch.position.y, patch.end.y):
			for x in range(patch.position.x, patch.end.x):
				var cell := Vector2i(x, y)
				var column := 0 if x == patch.position.x else (2 if x == patch.end.x - 1 else 1)
				var row := 0 if y == patch.position.y else (2 if y == patch.end.y - 1 else 1)

				layout[cell] = origin + Vector2i(column, row)
				available.erase(cell)

	# One-cell strips, inward corners and protrusions have no matching atlas tile.
	# Keep them blocked with standalone props; favor trees around forests.
	for cell in cells:
		if available.has(cell):
			if rng.randf() < (0.85 if is_forest else 0.15):
				layout[cell] = TREE_TILE
			else:
				layout[cell] = ROCK_TILES[rng.randi_range(0, ROCK_TILES.size() - 1)]


static func _largest_patch_at(
		start: Vector2i, available: Dictionary[Vector2i, bool]
	) -> Rect2i:
	# Nine-slice art can close rectangles at least 2x2, but has no inner corners.
	var best := Rect2i()
	var width := 0
	var height := 0

	while available.has(start + Vector2i(width, 0)):
		width += 1

	while width >= 2:
		var row_width := 0

		while row_width < width and available.has(start + Vector2i(row_width, height)):
			row_width += 1

		width = row_width
		height += 1

		if width >= 2 and height >= 2 and width * height > best.get_area():
			best = Rect2i(start, Vector2i(width, height))

	return best


static func _cell_before(a: Vector2i, b: Vector2i) -> bool:
	return a.y < b.y or (a.y == b.y and a.x < b.x)
