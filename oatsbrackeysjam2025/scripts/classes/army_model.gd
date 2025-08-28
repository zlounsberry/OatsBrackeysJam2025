extends Node3D

func _ready() -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_parallel(false).set_loops(999)
	var random_value: float = randf_range(0.5, 1.25)
	tween.tween_property(self, "position:y", 0.5, random_value)
	tween.tween_property(self, "position:y", 0.0, random_value)
