extends CanvasLayer

const CONFIRM_MENU = preload("res://scenes/confirm_menu.tscn")
const RULES_PAGE = preload("res://scenes/rules_page.tscn")

@export var attacker_player_id: int
@export var defender_player_id: int

signal player_confirmed(is_yes: bool, unit_count: int, is_attack_action: bool)
signal start_game


func open_confirm_menu(available_units: int, is_attack: bool, attacker_player_id: int, defender_player_id: int):
	var confirm_menu = CONFIRM_MENU.instantiate()
	confirm_menu.available_units = available_units
	confirm_menu.is_attack = is_attack
	if is_attack:
		confirm_menu.attacker_player_id = attacker_player_id
		confirm_menu.defender_player_id = defender_player_id
	add_child(confirm_menu)
	confirm_menu.player_selected_yes.connect(_on_confirm_menu_player_selected_yes)


func update_player_turn_label() -> void:
	$PlayerTurn.text = str("Player: ", GameState.current_player_turn + 1)


func _on_confirm_menu_player_selected_yes(is_yes: bool, unit_count: int, is_attack: bool) -> void:
	player_confirmed.emit(is_yes, unit_count, is_attack)


func _on_faction_selection_start_game() -> void:
	start_game.emit()


func _on_rules_pressed() -> void:
	var rules = RULES_PAGE.instantiate()
	add_child(rules)


func _on_home_pressed() -> void:
	GameState.reset_to_defaults()
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")


func _on_skip_turn_pressed() -> void:
	get_parent()._update_current_player(false)
