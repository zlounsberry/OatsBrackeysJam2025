extends Node2D

@export var faction_id: int

@onready var final_position: Vector2 = Vector2(1920/2, 1080/2)

func _ready() -> void:
	$Avatar.update_faction_id(faction_id, false)
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property($Avatar, "position:", final_position, 1.5)
