extends CanvasLayer

const CONFIRM_MENU = preload("res://scenes/confirm_menu.tscn")

signal player_confirmed(is_yes: bool, unit_count: int, is_attack_action: bool)
signal start_game
#signal menu_opened(is_attack_menu: bool)
#signal menu_closed(is_attack_menu: bool, is_canceled: bool)


#func _ready() -> void:
	#var confirm_menu = CONFIRM_MENU.instantiate()
	#add_child(confirm_menu)
	#confirm_menu.menu_opened.connect(_on_confirm_menu_menu_opened)
	#confirm_menu.menu_closed.connect(_on_confirm_menu_menu_closed)
	#confirm_menu.menu_closed.connect(_on_confirm_menu_menu_closed)
	#confirm_menu.player_selected_yes.connect(_on_confirm_menu_player_selected_yes)


func open_confirm_menu(available_units: int, is_attack: bool):
	var confirm_menu = CONFIRM_MENU.instantiate()
	confirm_menu.available_units = available_units
	confirm_menu.is_attack = is_attack
	add_child(confirm_menu)
	confirm_menu.player_selected_yes.connect(_on_confirm_menu_player_selected_yes)


func update_player_turn_label() -> void:
	$PlayerTurn.text = str("Player: ", GameState.current_player_turn + 1)


func _on_confirm_menu_player_selected_yes(is_yes: bool, unit_count: int, is_attack: bool) -> void:
	player_confirmed.emit(is_yes, unit_count, is_attack)


func _on_faction_selection_start_game() -> void:
	start_game.emit()


#func _on_confirm_menu_menu_opened() -> void:
	#menu_opened.emit()


#func _on_confirm_menu_menu_closed() -> void:
	#menu_closed.emit()
