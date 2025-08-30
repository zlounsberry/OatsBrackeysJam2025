extends Control

signal player_selected_yes(is_yes: bool, final_unit_count: int, is_attack_action:bool)
#signal menu_opened

@export var available_units: int # Note only attackers can specify attack numbers
@export var is_attack: bool = false
@export var attacker_player_id: int
@export var defender_player_id: int

@onready var can_interact: bool = false
@onready var unit_count: int = 1
@onready var move_unit_count_label: Label = $Move/UnitCount
@onready var attack_unit_count_label: Label = $Attack/UnitCount
@onready var final_position: Vector2 = Vector2(448.0, 256.0)


func _ready() -> void:
#	 Don't forget to start at scale = 0, below are some debug functions
	#is_attack = true
	tween_menu_in()


func tween_menu_in() -> void:
	GameState.menu_open = true
	#$Move/Avatar.faction_id_manual = GameState.current_player_dict[GameState.current_player_turn]["faction_id"]
	$Move/Avatar.update_faction_id(GameState.current_player_dict[GameState.current_player_turn]["faction_id"], false)
	#print("opening menu with attack: ", is_attack)
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	if is_attack:
		tween.tween_property($Attack, "position:", final_position, 0.5)
		$Attack/AttackerAvatar.update_faction_id(GameState.current_player_dict[attacker_player_id]["faction_id"], true)
		$Attack/DefenderAvatar.update_faction_id(GameState.current_player_dict[defender_player_id]["faction_id"], true)
	else:
		tween.tween_property($Move, "position:", final_position, 0.5)
	await tween.finished
	#menu_opened.emit()
	print("menu in")
	can_interact = true


func tween_menu_out() -> void:
	can_interact = false
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween.tween_property($Attack, "position:y", final_position.y + 1000, 0.5)
	tween.tween_property($Move, "position:y", final_position.y + 1000, 0.5)
	await tween.finished
	GameState.menu_open = false
	print("menu out")
	queue_free()


func _on_confirm_pressed() -> void:
	if not can_interact:
		return
	#print('confirmed')
	player_selected_yes.emit(true, unit_count, is_attack)
	tween_menu_out()


func _on_deny_pressed() -> void:
	if not can_interact:
		return
	#print('denied')
	player_selected_yes.emit(false, unit_count, is_attack)
	tween_menu_out()


func _on_subtract_pressed() -> void:
	if not can_interact:
		return
	if unit_count <= 1:
		return
	unit_count -= 1
	move_unit_count_label.text = str(unit_count)
	attack_unit_count_label.text = str(unit_count)


func _on_add_pressed() -> void:
	if not can_interact:
		return
	if unit_count >= available_units:
		return
	unit_count += 1
	move_unit_count_label.text = str(unit_count)
	attack_unit_count_label.text = str(unit_count)
