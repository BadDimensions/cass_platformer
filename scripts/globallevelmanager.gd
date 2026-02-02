extends Node

var current_tile_map_bounds : Array[ Vector2 ]
signal TileMapBoundsChanged(bounds : Array[ Vector2 ])

# Called when the node enters the scene tree for the first time.
func ChangeTileMapBounds(bounds : Array[ Vector2]) -> void:
	current_tile_map_bounds = bounds
	TileMapBoundsChanged.emit(bounds)
	pass 
