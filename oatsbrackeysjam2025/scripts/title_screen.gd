extends Node3D

const RULES_PAGE = preload("res://scenes/rules_page.tscn")

func _process(delta: float) -> void:
	$Marker3D.rotation.y += delta / 6

func _on_two_player_pressed() -> void:
	for button in $HUD/VBoxContainer.get_children():
		button.disabled = true
	var tween: Tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property($HUD/ColorRect, "modulate:a", 1, 1.5)
	GameState.number_of_players = 2
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/main.tscn")



func _on_three_player_pressed() -> void:
	for button in $HUD/VBoxContainer.get_children():
		button.disabled = true
	var tween: Tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property($HUD/ColorRect, "modulate:a", 1, 1.5)
	GameState.number_of_players = 3
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_rules_pressed() -> void:
	var rules = RULES_PAGE.instantiate()
	$HUD.add_child(rules)
