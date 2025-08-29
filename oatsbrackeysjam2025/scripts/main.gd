extends Node3D

const CHOCCY = preload("res://scenes/armies/choccy.tscn")
const JAMMER = preload("res://scenes/armies/jammer.tscn")
const SANDWICH_COOKIE = preload("res://scenes/armies/sandwich_cookie.tscn")
const DICE_TRAY = preload("res://scenes/dice_tray.tscn")

signal player_confirmed(is_yes: bool)
#signal army_defeated(is_defeated: bool)

@onready var moving_camera: bool = false
@onready var total_army_count: int = 0



func _input(event: InputEvent) -> void:
	if GameState.current_state < GameState.STATE_MACHINE.SELECTING_IN_GAME:
		return

	if moving_camera:
		return

	if event.is_action_pressed("switch_army"):
		select_next_army()

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
	for tile in get_tree().get_nodes_in_group("map_tile"):
		tile._hide_outline()
	for army_child: Army in get_tree().get_nodes_in_group("army"):
		if army_child.controlling_player_id == GameState.current_player_turn:
			army_child.select_this_army()
			set_adjacent_tiles_selectable(army_child.currently_occupied_tile.tile_id)
			return


func set_adjacent_tiles_selectable(tile_id: int) -> void:
	for map_tile in get_tree().get_nodes_in_group("map_tile"):
		map_tile.can_select = false
		map_tile._hide_outline()
	for map_id in GameState.TILE_ADJACENT_MAP_DICT[tile_id]:
		for map_tile: MapTile in get_tree().get_nodes_in_group("map_tile"):
			if map_id == map_tile.tile_id:
				map_tile.can_select = true


func select_next_army() -> void:
##	 Check out this clunky shit lmao
	var player_controlled_army_ids: Array = []
	var army_scene: Army
	var new_army_id: int
	for army_child: Army in get_tree().get_nodes_in_group("army"):
		if army_child.controlling_player_id == GameState.current_player_turn:
			player_controlled_army_ids.append(army_child.army_id)
	if GameState.current_selected_army == null:
		#prints("no current army rip", GameState.current_selected_army)
		return
	if GameState.current_selected_army.army_id == player_controlled_army_ids.max():
#		 Loop around to lowest value if it's the max value
		new_army_id = player_controlled_army_ids.min()
	else:
#		 Otherwise just grab the next value
		var current_array_position: int = player_controlled_army_ids.find(GameState.current_selected_army.army_id)
		new_army_id = player_controlled_army_ids[current_array_position + 1]
	for army_child: Army in get_tree().get_nodes_in_group("army"):
		if army_child.army_id == new_army_id:
			army_child.select_this_army()
			set_adjacent_tiles_selectable(army_child.currently_occupied_tile.tile_id)
			#prints("army_child.currently_occupied_tile.tile_id", army_child.currently_occupied_tile.tile_id)
			return
	#print("you borked it lol")


func _add_new_army_to_map_tile(map_tile: MapTile, player_value: int, new_army_size: int) -> void:
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
	new_army.currently_occupied_tile = map_tile
	new_army.army_size = new_army_size
	new_army.army_id = total_army_count
	add_child(new_army)
	map_tile.update_ownership(true, new_army)
	new_army.global_position = map_tile.get_node("Marker3D").global_position
	new_army.update_army_size_visuals()
	#prints("new army", new_army, "on tile", map_tile, new_army.currently_occupied_tile)


func _on_map_clicked_this_tile(clicked_tile_scene: MapTile, occupying_army: Army, tile_is_occupied: bool) -> void:
##	Receiving this signal means that a tile was clicked on and the signal made its way up here
## If tile_is_occupied is true, that means the clicked tile is currently occupied by occupying_army
## Otherwise, occupying_army is null and tile_is_occupied comes in false
	if not GameState.current_state == GameState.STATE_MACHINE.SELECTING_IN_GAME:
		#print('wrong state')
		return
	if GameState.current_selected_army == null:
		#print("no army selected!")
		return
	var current_army: Army = GameState.current_selected_army
	if tile_is_occupied:
#		 If the tile is occupied, ensure that the invading army and occupying army are not controlled by the same team
		if clicked_tile_scene.occupying_army.controlling_player_id == GameState.current_player_turn:
			GameState.update_state(GameState.STATE_MACHINE.SELECTING_IN_GAME) # Not sure this is needed
			return
		GameState.update_state(GameState.STATE_MACHINE.CONFIRMING_IN_GAME)
		_show_confirm_menu(current_army.army_size, true)
		var confirmed: Array = await player_confirmed 
#		 If the tile contains an army that is not controlled by the player, begin the attack phase by opening menu
		if confirmed[0]:
			_initiate_attack(current_army, occupying_army, confirmed[1])
	else:
#		 If the tile is not currently occupied, allow the player to move onto it
		GameState.update_state(GameState.STATE_MACHINE.CONFIRMING_IN_GAME)
		_show_confirm_menu(current_army.army_size, false)
		var confirmed: Array = await player_confirmed # Note the function that emits this signal also defines the units_to_move variable!
		_hide_confirm_menu()
		if confirmed[0]:
			#prints("army moving from", current_army.currently_occupied_tile, "to", clicked_tile_scene)
			current_army.move_to_new_space(current_army.currently_occupied_tile, clicked_tile_scene, confirmed[1])
			GameState.update_state(GameState.STATE_MACHINE.TRANSITIONING)
			await current_army.movement_complete
			_add_new_army_to_map_tile(clicked_tile_scene, -99, confirmed[1])
			#_add_new_army_to_map_tile(current_army.currently_occupied_tile, -99, confirmed[1]) # -99 means "use global variable for current player turn (not used in _on_hud_start_game())
			_update_current_player(false)
	GameState.update_state(GameState.STATE_MACHINE.SELECTING_IN_GAME)


func _initiate_attack(current_army: Army, occupying_army: Army, units_to_attack_with: int) -> void:
	#prints("initiate attack", current_army, occupying_army, units_to_attack_with)
	GameState.update_state(GameState.STATE_MACHINE.ATTACK_HAPPENING)
	var dice_tray: = DICE_TRAY.instantiate()
	dice_tray.attacker_army = current_army
	dice_tray.attacker_player_id = current_army.controlling_player_id
	dice_tray.attacker_army_size = units_to_attack_with # The 2nd variable in the player_confirmed array is the unit count, defined above
	dice_tray.defender_army = occupying_army
	dice_tray.defender_player_id = occupying_army.controlling_player_id
	dice_tray.defender_army_size = occupying_army.army_size
	$HUD.add_child(dice_tray)
	dice_tray.deal_damage_to_army.connect(_damage_armies)


func _damage_armies(
	attacker_army: Army,
	attacker_tile_id: MapTile, 
	attacker_damage_taken: int,
	defender_army: Army, 
	defender_tile_id: MapTile, 
	defender_damage_taken: int
) -> void:
#	Reminder update_ownership() occurs in remove_army_units_from_tile()
	#print("evaluating attack")
	if attacker_damage_taken > 0:
		#print("evaluating attack greater than 0")
		attacker_tile_id.remove_army_units_from_tile(attacker_damage_taken) # sets occupying_army.is_defeated = true if size <= 0. Otherwise just deals w/ updating visuals and stuff
	#print("evaluating defense")
	if defender_damage_taken > 0:
		#print("evaluating defense greater than 0")
		defender_tile_id.remove_army_units_from_tile(defender_damage_taken)


func _on_hud_player_confirmed(is_yes: bool, unit_count: int, is_attack: bool) -> void:
	player_confirmed.emit(is_yes, unit_count, is_attack)


func _on_hud_start_game() -> void:
	var array_of_tiles: Array = get_tree().get_nodes_in_group("map_tile")
	array_of_tiles.shuffle()
	for player_value in range(GameState.number_of_players):
		var map_tile: MapTile = array_of_tiles.pop_front()
		_add_new_army_to_map_tile(map_tile, player_value, 4) # Hardcoded to start game w/ 4 units per army
	#GameState.current_state = GameState.STATE_MACHINE.SELECTING_START
	_update_current_player(true)
