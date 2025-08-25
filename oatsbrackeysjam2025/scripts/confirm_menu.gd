extends CanvasLayer

signal player_selected_yes(is_yes: bool)


func _on_confirm_pressed() -> void:
	player_selected_yes.emit(true)


func _on_deny_pressed() -> void:
	player_selected_yes.emit(false)
