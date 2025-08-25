extends Node3D

const ARMY = preload("res://scenes/army.tscn")

enum STATE_MACHINE {
	DISABLED,
	SELECTING_START,
	CONFIRMING_START,
	SELECTING_IN_GAME,
	CONFIRMING_IN_GAME,
	TRANSITIONING,
	GAME_OVER,
}

signal player_confirmed(is_yes: bool)

#@onready var current_state: int = STATE_MACHINE.DISABLED
@onready var current_state: int = STATE_MACHINE.SELECTING_IN_GAME # For testing confirm button
@onready var current_player_turn: int = GameState.PLAYER_IDS.PLAYER_1

func _ready():
	for player_value in GameState.number_of_players:
		var new_army: Army = ARMY.instantiate()
		new_army.name = str("Army", player_value)
		add_child(new_army)
	current_state = STATE_MACHINE.SELECTING_START


func _show_confirm_menu():
	$HUD/ConfirmMenu.show()


func _hide_confirm_menu():
	$HUD/ConfirmMenu.hide()


func _on_map_clicked_this_tile(tile_position: Vector3) -> void:
	if not current_state == STATE_MACHINE.SELECTING_IN_GAME:
		return
	current_state = STATE_MACHINE.CONFIRMING_IN_GAME
	_show_confirm_menu()
	var confirmed: bool = await player_confirmed
	if confirmed:
		get_node(str("Army", current_player_turn)).move_to_new_space(tile_position)
		current_state = STATE_MACHINE.TRANSITIONING
		await get_node(str("Army", current_player_turn)).movement_complete
	else:
		pass


func _on_hud_player_confirmed(is_yes: bool) -> void:
	player_confirmed.emit(is_yes)
