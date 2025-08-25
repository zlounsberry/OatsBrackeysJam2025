extends Node3D
class_name Army


func move_to_new_space(new_position: Vector3) -> void:
	print(new_position)
	var htween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
	htween.tween_property(self, "global_position:z", new_position.z, 1)
	htween.tween_property(self, "global_position:x", new_position.x, 1)
	var vtween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(false)
	vtween.tween_property(self, "global_position:y", 3, 0.5)
	vtween.tween_property(self, "global_position:y", new_position.y, 0.5)
