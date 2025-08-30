extends Node2D
class_name Avatar

@export var faction_id_manual: int


func _ready() -> void:
	if get_parent().name == "FactionSelection":
		update_faction_id(faction_id_manual, false)


func update_faction_id(faction_id: int, is_attacker: bool) -> void:
	print("faction = ", faction_id, " from avi script")
	var move_position_to_avoid_overlap: float
	match faction_id:
		GameState.FACTIONS.SANDWICH_COOKIE:
			print("SANDWICH_COOKIE faction")
			move_position_to_avoid_overlap = 1500
			$"3DView/SubViewport/sandwich_cookie".show()
		GameState.FACTIONS.CHOCCY_CHIP:
			print("CHOCCY_CHIP faction")
			move_position_to_avoid_overlap = 2000
			$"3DView/SubViewport/choccy".show()
		GameState.FACTIONS.STRAWBRY_JAMMER:
			print("STRAWBRY_JAMMER faction")
			move_position_to_avoid_overlap = 2500
			$"3DView/SubViewport/jammer".show()
	for child in $"3DView/SubViewport".get_children():
			child.position.z += move_position_to_avoid_overlap
