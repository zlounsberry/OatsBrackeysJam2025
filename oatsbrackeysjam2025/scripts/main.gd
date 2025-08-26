extends Node3D

const ARMY = preload("res://scenes/army.tscn")

signal player_confirmed(is_yes: bool)


func _ready():
	for player_value in GameState.number_of_players:
		var new_army: Army = ARMY.instantiate()
		new_army.name = str("Army", player_value)
		add_child(new_army)
	GameState.current_state = GameState.STATE_MACHINE.SELECTING_START


func _show_confirm_menu():
	$HUD/ConfirmMenu.show()


func _hide_confirm_menu():
	$HUD/ConfirmMenu.hide()


func _update_current_player() -> void:
	if GameState.current_player_turn >= GameState.GameState.number_of_players:
		GameState.current_player_turn = GameState.GameState.PLAYER_IDS.PLAYER_1
	else:
		GameState.current_player_turn += 1
	$HUD.update_player_turn_label


func _on_map_clicked_this_tile(tile_position: Vector3) -> void:
	if not GameState.current_state == GameState.STATE_MACHINE.SELECTING_IN_GAME:
		return
	GameState.current_state = GameState.STATE_MACHINE.CONFIRMING_IN_GAME
	_show_confirm_menu()
	var confirmed: bool = await player_confirmed
	if confirmed:
		get_node(str("Army", GameState.current_player_turn)).move_to_new_space(tile_position)
		GameState.current_state = GameState.STATE_MACHINE.TRANSITIONING
		await get_node(str("Army", GameState.current_player_turn)).movement_complete
		_update_current_player()
		GameState.current_state = GameState.STATE_MACHINE.SELECTING_IN_GAME
	else:
		_hide_confirm_menu()
		GameState.current_state = GameState.STATE_MACHINE.SELECTING_IN_GAME


func _on_hud_player_confirmed(is_yes: bool) -> void:
	player_confirmed.emit(is_yes)
