extends CanvasLayer

signal player_confirmed(is_yes: bool, unit_count: int, is_attack_action: bool)
signal start_game


func update_player_turn_label() -> void:
	$PlayerTurn.text = str("Player: ", GameState.current_player_turn + 1)


func _on_confirm_menu_player_selected_yes(is_yes: bool, unit_count: int, is_attack: bool) -> void:
	player_confirmed.emit(is_yes, unit_count, is_attack)


func _on_faction_selection_start_game() -> void:
	start_game.emit()
