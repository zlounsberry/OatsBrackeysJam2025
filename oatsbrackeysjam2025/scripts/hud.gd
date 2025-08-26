extends CanvasLayer

signal player_confirmed(is_yes: bool)


func update_player_turn_label() -> void:
	$PlayerTurn.text = str("Player: ", GameState.current_player_turn)


func _on_confirm_menu_player_selected_yes(is_yes: bool) -> void:
	player_confirmed.emit(is_yes)
