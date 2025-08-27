extends Node3D

const CHOCCY = preload("res://scenes/armies/choccy.tscn")
const JAMMER = preload("res://scenes/armies/jammer.tscn")
const SANDWICH_COOKIE = preload("res://scenes/armies/sandwich_cookie.tscn")

signal player_confirmed(is_yes: bool)

@onready var moving_camera: bool = false
@onready var units_to_move: int = 0


func _input(event: InputEvent) -> void:
	if GameState.current_state < GameState.STATE_MACHINE.SELECTING_IN_GAME:
		return

	if moving_camera:
		return

	if event.is_action_pressed("ui_left"):
		print('rotating left')
		moving_camera = true
		var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property($Marker3D, "rotation:y",  $Marker3D.rotation.y + deg_to_rad(45), 0.5)
		await tween.finished
		moving_camera = false

	if event.is_action_pressed("ui_right"):
		print('rotating right')
		moving_camera = true
		var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property($Marker3D, "rotation:y", $Marker3D.rotation.y - deg_to_rad(45), 0.5)
		await tween.finished
		moving_camera = false


func _show_confirm_menu(available_units: int):
	$HUD/ConfirmMenu.available_units = available_units
	$HUD/ConfirmMenu.show()


func _hide_confirm_menu():
	$HUD/ConfirmMenu.hide()


func _update_current_player(initialize: bool) -> void:
	if GameState.current_player_turn >= (GameState.number_of_players - 1):
		GameState.current_player_turn = GameState.PLAYER_IDS.PLAYER_1
	else:
		GameState.current_player_turn += 1
	if initialize:
		GameState.current_player_turn = randi_range(0, GameState.number_of_players) # If this is the first selection, pick a random army
		prints("randomly selected", GameState.current_player_turn, "of", GameState.number_of_players)
	$HUD.update_player_turn_label()
	for army_child: Army in get_tree().get_nodes_in_group("army"):
		prints(army_child, army_child.controlling_player_id, GameState.current_player_turn)
		if army_child.controlling_player_id == GameState.current_player_turn:
			army_child.select_this_army()
			return


func select_next_army() -> void:
	pass


func _on_map_clicked_this_tile(tile_scene: MapTile) -> void:
	if not GameState.current_state == GameState.STATE_MACHINE.SELECTING_IN_GAME:
		print('wrong state')
		return
	if GameState.current_selected_army == null:
		print("no army sleected!")
		return
	var current_army: Army = GameState.current_selected_army
	GameState.current_state = GameState.STATE_MACHINE.CONFIRMING_IN_GAME
	_show_confirm_menu(current_army.army_size)
	var confirmed: bool = await player_confirmed # Note the function that emits this signal also defines the units_to_move variable!
	_hide_confirm_menu()
	if confirmed:
		current_army.move_to_new_space(current_army.currently_occupied_tile, tile_scene, units_to_move)
		GameState.current_state = GameState.STATE_MACHINE.TRANSITIONING
		await get_node(str("Army", GameState.current_player_turn)).movement_complete
		_update_current_player(false)
		GameState.current_state = GameState.STATE_MACHINE.SELECTING_IN_GAME
	else:
		GameState.current_state = GameState.STATE_MACHINE.SELECTING_IN_GAME


func _on_hud_player_confirmed(is_yes: bool, unit_count: int) -> void:
	units_to_move = unit_count
	player_confirmed.emit(is_yes)


func _on_hud_start_game() -> void:
	var array_of_tiles: Array = get_tree().get_nodes_in_group("map_tile")
	for player_value in range(GameState.number_of_players):
		var new_army: Army
		match GameState.current_player_dict[player_value]["faction_id"]:
			GameState.FACTIONS.SANDWICH_COOKIE:
				new_army = SANDWICH_COOKIE.instantiate()
			GameState.FACTIONS.CHOCCY_CHIP:
				new_army = CHOCCY.instantiate()
			GameState.FACTIONS.STRAWBRY_JAMMER:
				new_army = JAMMER.instantiate()
		new_army.controlling_player_id = player_value
		new_army.name = str("Army", player_value)
		array_of_tiles.shuffle()
		print("parray of tiles: ", array_of_tiles)
		var map_tile: MapTile = array_of_tiles.pop_front()
		print("map tile popped out: ", map_tile)
		new_army.currently_occupied_tile = map_tile
		map_tile.is_occupied = true
		map_tile.occupying_army = new_army
		add_child(new_army)
		GameState.current_player_dict[player_value]["current_armies"].append(new_army)
		new_army.global_position = map_tile.get_node("Marker3D").global_position
	print("game start!")
	#GameState.current_state = GameState.STATE_MACHINE.SELECTING_START
	_update_current_player(true)
