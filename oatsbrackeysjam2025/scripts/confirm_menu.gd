extends Node2D

signal player_selected_yes(is_yes: bool, amount: int)

@export var available_units: int

@onready var unit_count: int = 1


func _on_confirm_pressed() -> void:
	player_selected_yes.emit(true, unit_count)
	unit_count = 1 # Reset for next time
	$UnitCount.text = str(unit_count)


func _on_deny_pressed() -> void:
	player_selected_yes.emit(false, unit_count)
	unit_count = 1 # Reset for next time
	$UnitCount.text = str(unit_count)


func _on_subtract_pressed() -> void:
	if unit_count <= 1:
		return
	unit_count -= 1
	$UnitCount.text = str(unit_count)


func _on_add_pressed() -> void:
	if unit_count >= available_units:
		return
	unit_count += 1
	$UnitCount.text = str(unit_count)
