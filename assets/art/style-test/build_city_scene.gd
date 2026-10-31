extends SceneTree
## Run with --headless --path . --script assets/art/style-test/build_city_scene.gd.
## Produces an editable city scene. The game does not generate the map at runtime.

const DESTINATION := "res://scenes/walkable_city/tile_map_layer.tscn"
const MAP_SIZE := Vector2i(80, 48)
const CELL := 16

var city_map: Node2D
var ground: TileMapLayer
var objects: Node2D
var tiles: TileSet
var atlas: Texture2D
var entries: Dictionary = {}


func _initialize() -> void:
	call_deferred("build")


func attach(node: Node, parent: Node) -> void:
	parent.add_child(node, true)
	node.owner = city_map


func paint(tile_name: String, rect: Rect2i) -> void:
	var coords: Vector2i = entries[tile_name].coords
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			ground.set_cell(Vector2i(x, y), 0, coords)


func obstacle(parent: Node2D, rect: Rect2, node_name: String = "Obstacle") -> void:
	var body := StaticBody2D.new()
	body.name = node_name
	body.collision_layer = 1
	body.collision_mask = 2
	attach(body, parent)
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = rect.size
	shape.shape = rectangle
	shape.position = rect.get_center()
	attach(shape, body)


func label(parent: Node2D, text: String, position: Vector2, width: float) -> void:
	var panel := PanelContainer.new()
	panel.name = "LocationLabel"
	panel.position = position
	panel.custom_minimum_size = Vector2(width, 18)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color("2e222f")
	style.content_margin_left = 4
	style.content_margin_right = 4
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	panel.add_theme_stylebox_override("panel", style)
	attach(panel, parent)
	var title := Label.new()
	title.text = text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 12)
	title.add_theme_color_override("font_color", Color("c7dcd0"))
	attach(title, panel)


func sprite(parent: Node2D, tile_name: String, top_left: Vector2) -> void:
	var entry: Dictionary = entries[tile_name]
	var texture := AtlasTexture.new()
	texture.atlas = atlas
	texture.region = Rect2(Vector2(entry.coords) * CELL, Vector2(entry.size) * CELL)
	var image := Sprite2D.new()
	image.name = tile_name.to_pascal_case()
	image.texture = texture
	image.centered = false
	image.position = top_left
	attach(image, parent)


func building(
	node_name: String, title: String, rect: Rect2i, brick: bool, tall_windows: bool = false
) -> void:
	var building_node := Node2D.new()
	building_node.name = node_name
	var width := rect.size.x * CELL
	var height := rect.size.y * CELL
	building_node.position = Vector2(rect.position.x * CELL + width / 2.0, rect.end.y * CELL)
	attach(building_node, objects)
	var layer := TileMapLayer.new()
	layer.name = "BuildingTiles"
	layer.tile_set = tiles
	layer.position = Vector2(-width / 2.0, -height)
	attach(layer, building_node)
	var roof_rows := rect.size.y - 4
	for y in range(rect.size.y):
		for x in range(rect.size.x):
			var tile_name := "wall_brick" if brick else "wall_plaster"
			if y < roof_rows:
				tile_name = "roof_terracotta" if brick else "roof_slate"
			elif y == roof_rows:
				tile_name = "eave_brick" if brick else "eave_plaster"
			layer.set_cell(Vector2i(x, y), 0, entries[tile_name].coords)
	var left := -width / 2.0
	var door_column := floori(rect.size.x / 2.0)
	sprite(
		building_node,
		"door_glass" if brick else "door_wood",
		Vector2(left + door_column * CELL, -32)
	)
	for x in range(1, rect.size.x - 1, 2):
		if absi(x - door_column) <= 1:
			continue
		var tile_name := "window_brick" if brick else "window_plaster"
		if tall_windows:
			tile_name = "window_tall_lit" if brick else "window_tall_dark"
		sprite(building_node, tile_name, Vector2(left + x * CELL, -48))
	obstacle(building_node, Rect2(left, -height + 16, width, height - 16))
	label(building_node, title, Vector2(left + 8, -height - 20), width - 16)
	var entrance := Marker2D.new()
	entrance.name = "Entrance"
	entrance.position = Vector2(left + door_column * CELL + 8, 24)
	attach(entrance, building_node)
	building_node.set_meta("location_name", title)


func prop(tile_name: String, feet: Vector2) -> void:
	var node := Node2D.new()
	node.name = tile_name.to_pascal_case()
	node.position = feet
	attach(node, objects)
	var size := Vector2(entries[tile_name].size) * CELL
	sprite(node, tile_name, Vector2(-size.x / 2, -size.y))
	if tile_name.begins_with("tree"):
		obstacle(node, Rect2(-5, -6, 10, 6))
	elif tile_name.begins_with("lamp"):
		obstacle(node, Rect2(-3, -4, 6, 4))
	elif tile_name == "bench":
		obstacle(node, Rect2(-14, -8, 28, 8))
	else:
		obstacle(node, Rect2(-5, -6, 10, 6))


func build() -> void:
	tiles = load("res://assets/art/style-test/tiles_city.tres")
	atlas = load("res://assets/art/style-test/tiles_city_atlas.png")
	var manifest: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string("res://assets/art/style-test/tiles_city_manifest.json")
	)
	for entry: Dictionary in manifest.tiles:
		entries[entry.name] = {
			"coords": Vector2i(entry.atlas[0], entry.atlas[1]),
			"size": Vector2i(entry.size[0], entry.size[1])
		}
	city_map = Node2D.new()
	city_map.name = "CityMap"
	city_map.y_sort_enabled = true
	city_map.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root.add_child(city_map)
	ground = TileMapLayer.new()
	ground.name = "Ground"
	ground.tile_set = tiles
	ground.z_index = -2
	attach(ground, city_map)
	objects = Node2D.new()
	objects.name = "WorldObjects"
	objects.y_sort_enabled = true
	attach(objects, city_map)
	paint("grass", Rect2i(Vector2i.ZERO, MAP_SIZE))
	for y in range(MAP_SIZE.y):
		for x in range(MAP_SIZE.x):
			if (x * 17 + y * 31) % 19 == 0:
				paint("grass_autumn_leaves", Rect2i(x, y, 1, 1))
	# Continuous public sidewalks around the two intersecting streets.
	paint("sidewalk", Rect2i(0, 17, 80, 12))
	paint("sidewalk", Rect2i(35, 0, 11, 48))
	paint("asphalt", Rect2i(0, 20, 80, 6))
	paint("asphalt", Rect2i(38, 0, 5, 48))
	paint("road_mark_horizontal", Rect2i(0, 23, 80, 1))
	paint("road_mark_vertical", Rect2i(40, 0, 1, 48))
	paint("asphalt", Rect2i(38, 20, 5, 6))
	paint("curb_north", Rect2i(0, 19, 38, 1))
	paint("curb_north", Rect2i(43, 19, 37, 1))
	paint("curb_south", Rect2i(0, 26, 38, 1))
	paint("curb_south", Rect2i(43, 26, 37, 1))
	paint("curb_west", Rect2i(37, 0, 1, 19))
	paint("curb_west", Rect2i(37, 27, 1, 21))
	paint("curb_east", Rect2i(43, 0, 1, 19))
	paint("curb_east", Rect2i(43, 27, 1, 21))
	# Crosswalk stripes point across, rather than along, the direction of travel.
	for x in [8, 24, 54, 70]:
		paint("crosswalk_horizontal", Rect2i(x, 20, 2, 6))
	for y in [10, 32, 43]:
		paint("crosswalk_vertical", Rect2i(38, y, 5, 2))
	# Paths from the main pavement to entrances, including the southern campus.
	for x in [7, 23, 53, 69]:
		paint("sidewalk", Rect2i(x, 13, 3, 4))
	paint("sidewalk", Rect2i(26, 29, 3, 17))
	paint("sidewalk", Rect2i(12, 44, 24, 3))
	paint("sidewalk", Rect2i(13, 43, 3, 3))
	paint("sidewalk", Rect2i(29, 41, 3, 5))
	paint("sidewalk", Rect2i(28, 31, 8, 2))
	building("StudentHome", "Дом студента", Rect2i(4, 5, 9, 8), false)
	building("Museum", "Музей", Rect2i(18, 4, 13, 9), false, true)
	building("Archive", "Архив", Rect2i(49, 5, 11, 8), true, true)
	building("Cinema", "Кинотеатр «Октябрь»", Rect2i(64, 5, 12, 9), true)
	building("University", "Университет", Rect2i(4, 33, 20, 10), false, true)
	building("Cafe", "Кофейня", Rect2i(26, 33, 8, 8), true)
	# Park loop with four clear entrances and an open center.
	paint("sidewalk", Rect2i(46, 34, 31, 2))
	paint("sidewalk", Rect2i(48, 40, 29, 2))
	paint("sidewalk", Rect2i(48, 34, 2, 8))
	paint("sidewalk", Rect2i(75, 34, 2, 8))
	paint("sidewalk", Rect2i(61, 29, 3, 17))
	paint("sidewalk", Rect2i(56, 36, 14, 4))
	var park := Node2D.new()
	park.name = "Park"
	park.position = Vector2(62 * CELL, 31 * CELL)
	attach(park, objects)
	label(park, "Сквер", Vector2(-40, -20), 80)
	for x in [51, 57, 67, 73]:
		prop("tree_ochre" if x < 62 else "tree_olive", Vector2(x * CELL, 33 * CELL))
		prop("tree_olive", Vector2(x * CELL, 45 * CELL))
	for x in [53, 58, 68, 72]:
		prop("bench", Vector2(x * CELL, 39 * CELL))
	for x in [50, 74]:
		prop("lamp_lit", Vector2(x * CELL, 34 * CELL))
		prop("lamp_lit", Vector2(x * CELL, 43 * CELL))
	for x in [53, 71]:
		prop("shrub", Vector2(x * CELL, 37 * CELL))
		prop("litter_bin", Vector2(x * CELL + 24, 39 * CELL))
	# Street lighting leaves all crossings and door paths clear.
	for x in [3, 16, 32, 47, 62, 77]:
		prop("lamp_lit", Vector2(x * CELL + 8, 18 * CELL + 8))
		prop("lamp_lit", Vector2(x * CELL + 8, 28 * CELL))
	for x in [2, 15, 33, 47, 62, 78]:
		prop("tree_ochre", Vector2(x * CELL, 15 * CELL))
	for x in [3, 16, 32, 47, 62, 77]:
		prop("tree_olive", Vector2(x * CELL, 2 * CELL + 8))
	for x in [4, 19, 30]:
		prop("bench", Vector2(x * CELL, 30 * CELL))
	for x in [2, 24, 34]:
		prop("tree_ochre", Vector2(x * CELL, 46 * CELL))
	obstacle(city_map, Rect2(-16, -16, 1312, 16), "NorthBoundary")
	obstacle(city_map, Rect2(-16, 768, 1312, 16), "SouthBoundary")
	obstacle(city_map, Rect2(-16, 0, 16, 768), "WestBoundary")
	obstacle(city_map, Rect2(1280, 0, 16, 768), "EastBoundary")
	city_map.set_meta("map_size", Vector2i(1280, 768))
	city_map.set_meta("style_test", true)
	var scene := PackedScene.new()
	assert(scene.pack(city_map) == OK)
	assert(ResourceSaver.save(scene, DESTINATION) == OK)
	assert(ResourceSaver.set_uid(DESTINATION, ResourceUID.text_to_id("uid://ps4p66sdphoh")) == OK)
	print("Saved editable city: 1280x768, six buildings, park, paths, props and collision bodies.")
	quit()
