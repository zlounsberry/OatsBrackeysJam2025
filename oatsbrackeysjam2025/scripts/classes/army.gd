extends Node3D
class_name Army

signal movement_complete

const CC = preload("res://assets/resources/CC.tres")
const SCC = preload("res://assets/resources/SCC.tres")
const SJ = preload("res://assets/resources/SJ.tres")

@export var is_ai: bool = false
@export var currently_taking_turn: bool = false
@export var faction_id: int = 0


func skin_self(faction_id: int):
	match faction_id:
		GameState.FACTIONS.SANDWICH_COOKIE_CHAN:
			$CSGMesh3D.material_override = SCC
		GameState.FACTIONS.CHOCCY_CHIP:
			$CSGMesh3D.material_override = CC
		GameState.FACTIONS.STRAWBRY_JAMMER:
			$CSGMesh3D.material_override = SJ


func move_to_new_space(new_position: Vector3) -> void:
	if not currently_taking_turn:
		return
	print(new_position)
	var htween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
	htween.tween_property(self, "global_position:z", new_position.z, 1)
	htween.tween_property(self, "global_position:x", new_position.x, 1)
	var vtween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(false)
	vtween.tween_property(self, "global_position:y", 3, 0.5)
	vtween.tween_property(self, "global_position:y", new_position.y, 0.5)
	await htween.finished
	movement_complete.emit()
