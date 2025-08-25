extends Node3D

func _move_player(player, position):
	pass


func _on_map_clicked_this_tile(tile_position: Vector3) -> void:
	$Army.move_to_new_space(tile_position)
