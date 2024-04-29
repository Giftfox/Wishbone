extends TileMap

var terrain_info = {
	Enums.Terrain.sand: [Vector2i(1,1), Vector2i(2,1), Vector2i(3,1), Vector2i(4,1), Vector2i(5,1), Vector2i(6,1), Vector2i(7,1), Vector2i(8,1), Vector2i(9,1)]
}

@export var terrain_layers : Array[int] = []

func _ready():
	Global.current_tilemaps.append(self)

func seek_terrain(pos):
	var types = []
	var cell = local_to_map(to_local(pos))
	for l in terrain_layers:
		var tile = get_cell_atlas_coords(l, cell)
		for t in terrain_info.keys():
			if terrain_info[t].has(tile) and !types.has(t):
				types.append(t)
	return types
