extends GridContainer

export var tile_button_scene : PackedScene
export var object_button_scene : PackedScene

var current_tileset = null

signal update_selected_tile
signal update_selected_object

# Fills the Tiles container with all the tiles within the tileset of the tilemap
func show_tiles_from_tilemap(tilemap : TileMap):
	# Get the tilemap's TileSet
	var tileset = tilemap.get_tileset()
	
	# If we're already using the tileset, don't repopulatie the tiles container
	if current_tileset == tileset: return
	
	empty_tiles()
	current_tileset = tileset
	
	var tile_ids = tileset.get_tiles_ids()
	
	# Create an array of every tile which is in a group for the TileMap.
	var group_tiles = []
	if tilemap.is_in_group("stc_tilemaps"):
		for array in tilemap.group_tiles.values():
			group_tiles.append_array(array)
	
	for tile in tile_ids:
		
		var tile_name = tileset.tile_get_name(tile)
		
		# SuperTux Classic tilemaps have some custom properties, like groups of tiles and tiles to be ignored by the tiles editor
		if tilemap.is_in_group("stc_tilemaps"):
			# If the tile is in the ignored tiles list, don't add it to the list of tiles.
			if tilemap.ignore_tiles.has(tile_name): continue
		
			# If the tile is in a group,
			if group_tiles.has(tile_name):
				# If that tile is not the main tile of the group, don't add it to the list of tiles.
				if !tilemap.group_tiles.has(tile_name):
					continue
		
		var tile_button = tile_button_scene.instance()
		add_child(tile_button)
		tile_button.set_owner(self)
		tile_button.connect("tile_button_pressed", self, "update_selected_tile")
		tile_button.tileset = current_tileset
		tile_button.tile_id = tile

# Display all object scenes within a directory
func show_object_scenes_in_folder(folder_name : String):
	empty_tiles()
	current_tileset = null
	
	var object_files = Global.get_all_scene_files_in_folder(folder_name)
	
	for file in object_files:
		var object_resource = load(file)
		
		var is_object_allowed = true
		var object = object_resource.instance()
		print(object.name)
		if object.is_in_group("players"): is_object_allowed = false
		object.queue_free()
		if !is_object_allowed: continue
		
		var object_button = object_button_scene.instance()
		add_child(object_button)
		object_button.set_owner(self)
		object_button.connect("object_button_pressed", self, "update_selected_object")
		object_button.object_resource = object_resource


# Empties all tiles in the tile container
func empty_tiles():
	current_tileset = null
	
	for tile_button in get_children():
		tile_button.queue_free()

func update_selected_tile(selected_tile_id : int):
	emit_signal("update_selected_tile", selected_tile_id)
	for tile_button in get_children():
		tile_button.disabled = tile_button.tile_id == selected_tile_id

func update_selected_object(selected_object_resource : Resource):
	emit_signal("update_selected_object", selected_object_resource)
	
	for object_button in get_children():
		object_button.disabled = object_button.object_resource == selected_object_resource
