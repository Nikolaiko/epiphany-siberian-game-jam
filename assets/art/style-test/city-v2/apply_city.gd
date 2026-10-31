extends SceneTree
## Replaces only visual resources in the current city; layout and physics remain intact.

const DIRECTORY := "res://assets/art/style-test/city-v2/"
const SCENE := "res://scenes/walkable_city/tile_map_layer.tscn"


func _initialize() -> void:
	call_deferred("run")


func tile_set(file: String) -> TileSet:
	var texture := load(DIRECTORY + file + ".png") as Texture2D
	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(16, 16)
	var result := TileSet.new()
	result.tile_size = Vector2i(16, 16)
	result.add_source(source, 0)
	for y in range(texture.get_height() / 16):
		for x in range(texture.get_width() / 16):
			source.create_tile(Vector2i(x, y))
	assert(ResourceSaver.save(result, DIRECTORY + file + "_tiles.tres") == OK)
	return result


func run() -> void:
	var scene := load(SCENE).instantiate() as Node2D
	root.add_child(scene)
	var ground: TileMapLayer = scene.get_node("Ground")
	ground.tile_set = tile_set("terrain")
	var buildings := {
		"StudentHome": "home",
		"Museum": "museum",
		"Archive": "archive",
		"Cinema": "cinema",
		"University": "university",
		"Cafe": "cafe"
	}
	var objects: Node2D = scene.get_node("WorldObjects")
	for node_name: String in buildings:
		var building: Node2D = objects.get_node(node_name)
		var layer: TileMapLayer = building.get_node("BuildingTiles")
		var replacement := tile_set(buildings[node_name])
		layer.clear()
		layer.tile_set = replacement
		var source := replacement.get_source(0) as TileSetAtlasSource
		for index in range(source.get_tiles_count()):
			var coords := source.get_tile_id(index)
			layer.set_cell(coords, 0, coords)
		for child in building.get_children():
			if child is Sprite2D:
				child.free()
		var panel: PanelContainer = building.get_node("LocationLabel")
		panel.custom_minimum_size.x = 0
		panel.size = panel.get_combined_minimum_size()
		panel.position.x = -panel.size.x / 2
		var style := panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		style.bg_color = Color("3e3546")
		panel.add_theme_stylebox_override("panel", style)
	for object in objects.get_children():
		if buildings.has(String(object.name)):
			continue
		for child in object.get_children():
			if child is Sprite2D:
				var name_snake := String(child.name).to_snake_case()
				var path := DIRECTORY + name_snake + ".png"
				if ResourceLoader.exists(path):
					child.texture = load(path)
					var size: Vector2 = child.texture.get_size()
					child.position = Vector2(-size.x / 2, -size.y)
	scene.set_meta("art_revision", "city-v2-daytime")
	var packed := PackedScene.new()
	assert(packed.pack(scene) == OK)
	assert(ResourceSaver.save(packed, SCENE) == OK)
	assert(ResourceSaver.set_uid(SCENE, ResourceUID.text_to_id("uid://ps4p66sdphoh")) == OK)
	print("Applied city v2 artwork; layout, physics, entrances and camera unchanged.")
	quit()
