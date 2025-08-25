extends CanvasLayer

signal player_confirmed(is_yes: bool)


func _on_confirm_menu_player_selected_yes(is_yes: bool) -> void:
	player_confirmed.emit(is_yes)
