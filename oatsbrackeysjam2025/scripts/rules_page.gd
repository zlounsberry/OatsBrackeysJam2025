extends Node2D

@onready var toggle_rules_visible: bool = false

func _ready() -> void:
	tween_menu_in()


func tween_menu_in() -> void:
	GameState.menu_open = true
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position", Vector2.ZERO, 1)
	await tween.finished


func tween_menu_out() -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position", Vector2(0,2000), 0.8)
	await tween.finished
	GameState.menu_open = false
	queue_free()


func _on_button_pressed() -> void:
	if toggle_rules_visible:
		$HowToPlay.hide()
		$Rules.show()
		$Toggle.text = "How To Play"
		toggle_rules_visible = false
	else:
		$HowToPlay.show()
		$Rules.hide()
		$Toggle.text = "Rules"
		toggle_rules_visible = true


func _on_exit_pressed() -> void:
	tween_menu_out()
