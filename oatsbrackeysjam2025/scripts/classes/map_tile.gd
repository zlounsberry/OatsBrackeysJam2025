extends MeshInstance3D
class_name MapTile

signal clicked_this_tile(self_id: MapTile, occupying_army: Army, tile_is_occupied: bool)

@onready var can_select: bool = false
@onready var is_hovered: bool = false

@export var continent_id: int = 0
@export var tile_id: int

var is_occupied: bool = false
var occupying_army: Army
var adjacent_tiles: Array = []


func _ready() -> void:
	add_to_group("map_tile")
	$StaticBody3D.mouse_entered.connect(_show_outline)
	$StaticBody3D.mouse_exited.connect(_hide_outline)
	adjacent_tiles = GameState.TILE_ADJACENT_MAP_DICT[tile_id]
	prints(tile_id, "adjacent: ", adjacent_tiles)


func _process(_delta: float) -> void:
	$DEBUG.text = str(is_occupied)


func _input(event: InputEvent) -> void:
	if GameState.STATE_MACHINE.DISABLED:
		return
	if event.is_action_pressed("left_click"):
		if GameState.menu_open:
			return
		if is_hovered:
			if is_occupied:
				if occupying_army == null:
					print("edge case!")
					clicked_this_tile.emit(self, null, false) # Edge case where tile isn't occupied TODO: Consider removing if it fucks up!
					return
				print("tile is occupied from tile map class script", self, is_occupied, occupying_army)
				clicked_this_tile.emit(self, occupying_army, true)
			else:
				print("tile is not occupied from tile map class script", self, is_occupied, occupying_army)
				clicked_this_tile.emit(self, null, false)


func remove_army_units_from_tile(unit_count: int):
	# Kicked off by _damage_armies in main.gd using the deal_damage_to_army signal from dice_tray.gd
	print("removing army from ", self, occupying_army)
	if occupying_army == null:
		print("occupying army is null oop", self, occupying_army)
		return
	occupying_army.army_size -= unit_count
	occupying_army.update_army_size_visuals()
	var player_id_for_army = occupying_army.controlling_player_id
	if occupying_army.army_size <= 0:
		print("removing army, size <= 0")
		update_ownership(false, null)
		var remaining_player_array = []
		#occupying_army.queue_free()
		for army_child in get_tree().get_nodes_in_group("army"):
			remaining_player_array.append(army_child.controlling_player_id)
		if not remaining_player_array.has(player_id_for_army):
			prints("player", player_id_for_army, "eliminated!")
			GameState.current_player_dict[player_id_for_army]["is_eliminated"] = true


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
	if not can_select:
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
