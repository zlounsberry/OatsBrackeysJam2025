extends Node3D

const CHOCCY = preload("res://scenes/armies/choccy.tscn")
const JAMMER = preload("res://scenes/armies/jammer.tscn")
const SANDWICH_COOKIE = preload("res://scenes/armies/sandwich_cookie.tscn")

signal player_confirmed(is_yes: bool)

@onready var moving_camera: bool = false
@onready var units_to_move: int = 0
@onready var total_army_count: int = 0


func _input(event: InputEvent) -> void:
	if GameState.current_state < GameState.STATE_MACHINE.SELECTING_IN_GAME:
		return

	if moving_camera:
		return

	if event.is_action_pressed("ui_end"):
		#DEBUG CAMERA TOP VIEW
		$Marker3D.rotation_degrees.x = -32

	if event.is_action_pressed("ui_left"):
		moving_camera = true
		var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property($Marker3D, "rotation:y",  $Marker3D.rotation.y + deg_to_rad(45), 0.5)
		await tween.finished
		moving_camera = false

	if event.is_action_pressed("ui_right"):
		moving_camera = true
		var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property($Marker3D, "rotation:y", $Marker3D.rotation.y - deg_to_rad(45), 0.5)
		await tween.finished
		moving_camera = false
	
	if event.is_action_pressed("switch_army"):
		var new_army: Army
		if GameState.current_state <= GameState.STATE_MACHINE.SELECTING_IN_GAME:
			return


func _show_confirm_menu(available_units: int, is_attack_action: bool):
	$HUD.open_confirm_menu(available_units, is_attack_action)


func _hide_confirm_menu():
	$HUD/ConfirmMenu.tween_menu_out()


func _update_current_player(initialize: bool) -> void:
	if GameState.current_player_turn >= (GameState.number_of_players - 1):
		GameState.current_player_turn = GameState.PLAYER_IDS.PLAYER_1
	else:
		GameState.current_player_turn += 1
	if initialize:
		GameState.current_player_turn = randi_range(0, (GameState.number_of_players - 1)) # If this is the first selection, pick a random army
	$HUD.update_player_turn_label()
	for army_child: Army in get_tree().get_nodes_in_group("army"):
		if army_child.controlling_player_id == GameState.current_player_turn:
			GameState.current_tile_id = army_child.currently_occupied_tile.tile_id
			army_child.select_this_army()
			set_adjacent_tiles_selectable()
			return


func set_adjacent_tiles_selectable() -> void:
	for map_tile in get_tree().get_nodes_in_group("map_tile"):
		map_tile.can_select = false
	for map_id in GameState.TILE_ADJACENT_MAP_DICT[GameState.current_tile_id]:
		for map_tile: MapTile in get_tree().get_nodes_in_group("map_tile"):
			if map_id == map_tile.tile_id:
				map_tile.can_select = true


func select_next_army() -> void:
	pass


func _add_new_army(map_tile: MapTile, player_value: int, new_army_size: int) -> void:
	var new_army: Army
	total_army_count += 1
	if player_value == -99:
		player_value = GameState.current_player_turn
	match GameState.current_player_dict[player_value]["faction_id"]:
		GameState.FACTIONS.SANDWICH_COOKIE:
			new_army = SANDWICH_COOKIE.instantiate()
		GameState.FACTIONS.CHOCCY_CHIP:
			new_army = CHOCCY.instantiate()
		GameState.FACTIONS.STRAWBRY_JAMMER:
			new_army = JAMMER.instantiate()
	new_army.controlling_player_id = player_value
	new_army.name = str("Army", player_value)
	new_army.currently_occupied_tile = map_tile
	new_army.army_size = new_army_size
	new_army.army_id = total_army_count
	add_child(new_army)
	map_tile.update_ownership(true, new_army)
	new_army.update_army_size_visuals()
	new_army.global_position = map_tile.get_node("Marker3D").global_position


func _on_map_clicked_this_tile(tile_scene: MapTile, occupying_army: Army, tile_is_occupied: bool) -> void:
##	Receiving this signal means that a tile was clicked on and the signal made its way up here
## If tile_is_occupied is true, that means the clicked tile is currently occupied by occupying_army
## Otherwise, occupying_army is null and tile_is_occupied comes in false
	if not GameState.current_state == GameState.STATE_MACHINE.SELECTING_IN_GAME:
		print('wrong state')
		return
	if GameState.current_selected_army == null:
		print("no army selected!")
		return
	var current_army: Army = GameState.current_selected_army
	if tile_is_occupied:
#		 If the tile is occupied, ensure that the invading army and occupying army are not controlled by the same team
		print("This tile is occupied from main script!")
		if tile_scene.occupying_army.controlling_player_id == GameState.current_player_turn:
			print("cannot attack self!")
			GameState.update_state(GameState.STATE_MACHINE.SELECTING_IN_GAME) # Not sure this is needed
			return
		GameState.update_state(GameState.STATE_MACHINE.CONFIRMING_IN_GAME)
		_show_confirm_menu(current_army.army_size, true)
		var confirmed: bool = await player_confirmed 
		if confirmed:
			GameState.update_state(GameState.STATE_MACHINE.ATTACK_HAPPENING)
			prints("menu closed, fight time!")
	else:
		GameState.update_state(GameState.STATE_MACHINE.CONFIRMING_IN_GAME)
		_show_confirm_menu(current_army.army_size, false)
		var confirmed: bool = await player_confirmed # Note the function that emits this signal also defines the units_to_move variable!
		_hide_confirm_menu()
		if confirmed:
			current_army.move_to_new_space(current_army.currently_occupied_tile, tile_scene, units_to_move)
			GameState.update_state(GameState.STATE_MACHINE.TRANSITIONING)
			await current_army.movement_complete
			_add_new_army(current_army.currently_occupied_tile, -99, units_to_move) # -99 means "use global variable for current player turn (not used in _on_hud_start_game())
			_update_current_player(false)
	units_to_move = 0 # Just reset this for good measure
	GameState.update_state(GameState.STATE_MACHINE.SELECTING_IN_GAME)


func _on_hud_player_confirmed(is_yes: bool, unit_count: int, is_attack: bool) -> void:
	units_to_move = unit_count
	player_confirmed.emit(is_yes)


func _on_hud_start_game() -> void:
	var array_of_tiles: Array = get_tree().get_nodes_in_group("map_tile")
	array_of_tiles.shuffle()
	for player_value in range(GameState.number_of_players):
		var map_tile: MapTile = array_of_tiles.pop_front()
		_add_new_army(map_tile, player_value, 4) # Hardcoded to start game w/ 4 units per army
	#GameState.current_state = GameState.STATE_MACHINE.SELECTING_START
	_update_current_player(true)
