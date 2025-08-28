extends Node3D

signal clicked_this_tile(tile_id: MapTile, occupying_army: Army, tile_is_occupied: bool)

func _ready() -> void:
	for tile in $TilesMap.get_children():
		tile.clicked_this_tile.connect(_click_tile)


func _click_tile(tile_id: MapTile, occupying_army: Army, tile_is_occupied: bool):
	clicked_this_tile.emit(tile_id, occupying_army, tile_is_occupied)
