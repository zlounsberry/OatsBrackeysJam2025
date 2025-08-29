extends Control

signal player_selected_yes(is_yes: bool, final_unit_count: int, is_attack_action:bool)
#signal menu_opened

@export var available_units: int # Note only attackers can specify attack numbers
@export var is_attack: bool = false

@onready var can_interact: bool = false
@onready var unit_count: int = 1
@onready var move_unit_count_label: Label = $Move/UnitCount
@onready var attack_unit_count_label: Label = $Attack/UnitCount


func _ready() -> void:
##	 Don't forget to start at scale = 0, below are some debug functions
	#is_attack = true
	tween_menu_in()


func tween_menu_in() -> void:
	GameState.menu_open = true
	#print("opening menu with attack: ", is_attack)
	if is_attack:
		$Attack.show()
	else:
		$Move.show()
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2.ONE, 0.5)
	await tween.finished
	#menu_opened.emit()
	can_interact = true


func tween_menu_out() -> void:
	can_interact = false
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.25)
	await tween.finished
	GameState.menu_open = false
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
