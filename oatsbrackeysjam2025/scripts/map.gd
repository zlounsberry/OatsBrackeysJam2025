extends Node3D

signal clicked_this_tile(tile_position: Vector3)

func _ready() -> void:
	for tile in $Tiles.get_children():
		tile.clicked_this_tile.connect(_click_tile)


func _click_tile(tile_position: Vector3):
	clicked_this_tile.emit(tile_position)
