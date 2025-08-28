extends MeshInstance3D
class_name MapTile

signal clicked_this_tile(self_id: MapTile, occupying_army: Army, tile_is_occupied: bool)

@onready var is_hovered: bool = false

@export var continent_id: int = 0

var is_occupied: bool = false
var occupying_army: Army


func _ready() -> void:
	add_to_group("map_tile")
	$StaticBody3D.mouse_entered.connect(_show_outline)
	$StaticBody3D.mouse_exited.connect(_hide_outline)


func _process(delta: float) -> void:
	$DEBUG.text = str(is_occupied)


func _input(event: InputEvent) -> void:
	if GameState.STATE_MACHINE.DISABLED:
		return
	if event.is_action_pressed("left_click"):
		if GameState.menu_open:
			return
		if is_hovered:
			if is_occupied:
				print("tile is occupied from tile map class script", self, is_occupied, occupying_army)
				clicked_this_tile.emit(self, occupying_army, true)
			else:
				print("tile is not occupied from tile map class script", self, is_occupied, occupying_army)
				clicked_this_tile.emit(self, null, false)


#func remove_army_units_from_tile(army_scene: Army, unit_count: int):
	#army_scene.army_size -= unit_count
	#if army_scene.army_size <= 0:
		#print("removing army, size <= 0")
		#update_ownership(false, null)
		#army_scene.queue_free()


func update_ownership(tile_is_occupied: bool, army_scene: Army) -> void:
##	 If the tile is now occupied, tile_is_occupied = true and army_scene is the scene of the occupying army
##	 If the tile was occupied and now is not, tile_is_occupied = false and army_scene is null
	if tile_is_occupied:
		prints("tile now occupied", army_scene, army_scene.controlling_player_id, army_scene.army_id, self)
		occupying_army = army_scene
		is_occupied = true
	else:
		prints("tile not occupied anymore", self)
		occupying_army = null
		is_occupied = false


func _show_outline():
	if GameState.STATE_MACHINE.DISABLED:
		return
	if GameState.menu_open:
		return
	for tile in get_tree().get_nodes_in_group("map_tile"):
		tile._hide_outline()
	is_hovered = true
	$MeshInstance3D.show()


func _hide_outline():
	if GameState.STATE_MACHINE.DISABLED:
		return
	if GameState.menu_open:
		return
	is_hovered = false
	$MeshInstance3D.hide()
