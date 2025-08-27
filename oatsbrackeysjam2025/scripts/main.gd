extends Node3D

const ARMY = preload("res://scenes/army.tscn")

signal player_confirmed(is_yes: bool)

@onready var moving_camera: bool = false


func _input(event: InputEvent) -> void:
	if GameState.current_state == GameState.STATE_MACHINE.DISABLED:
		return

	if moving_camera:
		print('nah')
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


func _show_confirm_menu():
	$HUD/ConfirmMenu.show()


func _hide_confirm_menu():
	$HUD/ConfirmMenu.hide()


func _update_current_player() -> void:
	if GameState.current_player_turn >= (GameState.number_of_players - 1):
		GameState.current_player_turn = GameState.PLAYER_IDS.PLAYER_1
	else:
		GameState.current_player_turn += 1
	get_node(str("Army", GameState.current_player_turn)).currently_taking_turn = true
	$HUD.update_player_turn_label()


func _on_map_clicked_this_tile(tile_position: Vector3) -> void:
	if not GameState.current_state == GameState.STATE_MACHINE.SELECTING_IN_GAME:
		print('wrong state')
		return
	GameState.current_state = GameState.STATE_MACHINE.CONFIRMING_IN_GAME
	_show_confirm_menu()
	var confirmed: bool = await player_confirmed
	if confirmed:
		_hide_confirm_menu()
		print(get_node(str("Army", GameState.current_player_turn)))
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


func _on_hud_start_game() -> void:
	for player_value in GameState.number_of_players:
		var new_army: Army = ARMY.instantiate()
		new_army.controlling_player_id = player_value
		new_army.name = str("Army", player_value)
		add_child(new_army)
		new_army.skin_self(GameState.current_player_dict[player_value]["faction_id"])
	#GameState.current_state = GameState.STATE_MACHINE.SELECTING_START
	_update_current_player()
