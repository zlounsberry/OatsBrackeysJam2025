extends Node2D


func update_faction_id(faction_id: int, is_attacker: bool) -> void:
	print("faction = ", faction_id, " from avi script")
	if is_attacker:
		for child in $"3DView/SubViewport".get_children():
			child.position.x += 500
	else:
		for child in $"3DView/SubViewport".get_children():
			child.position.z += 500
	match faction_id:
		GameState.FACTIONS.SANDWICH_COOKIE:
			print("SANDWICH_COOKIE faction")
			$"3DView/SubViewport/sandwich_cookie".show()
		GameState.FACTIONS.CHOCCY_CHIP:
			print("CHOCCY_CHIP faction")
			$"3DView/SubViewport/choccy".show()
		GameState.FACTIONS.STRAWBRY_JAMMER:
			print("STRAWBRY_JAMMER faction")
			$"3DView/SubViewport/jammer".show()
