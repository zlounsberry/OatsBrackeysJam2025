extends Node2D
class_name Avatar

@export var faction_id_manual: int


func _ready() -> void:
	if get_parent().name == "FactionSelection":
		update_faction_id(faction_id_manual, false)


func update_faction_id(faction_id: int, is_attacker: bool) -> void:
	var move_position_to_avoid_overlap: float
	faction_id_manual = faction_id
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


func _take_damage():
	match faction_id_manual:
		GameState.FACTIONS.SANDWICH_COOKIE:
			$"3DView/SubViewport/sandwich_cookie/AnimatedSprite3D".hide()
			$"3DView/SubViewport/sandwich_cookie/HurtSprite".show()
		GameState.FACTIONS.CHOCCY_CHIP:
			$"3DView/SubViewport/sandwich_cookie/AnimatedSprite3D".hide()
			$"3DView/SubViewport/choccy/HurtSprite".show()
		GameState.FACTIONS.STRAWBRY_JAMMER:
			$"3DView/SubViewport/sandwich_cookie/AnimatedSprite3D".hide()
			$"3DView/SubViewport/jammer/HurtSprite".show()
	$AnimationPlayer.play("take_damage")
	


func _show_face():
	match faction_id_manual:
		GameState.FACTIONS.SANDWICH_COOKIE:
			$"3DView/SubViewport/sandwich_cookie/HurtSprite".hide()
			$"3DView/SubViewport/sandwich_cookie/AnimatedSprite3D".show()
		GameState.FACTIONS.CHOCCY_CHIP:
			$"3DView/SubViewport/choccy/HurtSprite".hide()
			$"3DView/SubViewport/choccy/AnimatedSprite3D".show()
		GameState.FACTIONS.STRAWBRY_JAMMER:
			$"3DView/SubViewport/jammer/HurtSprite".hide()
			$"3DView/SubViewport/jammer/AnimatedSprite3D".show()


func _show_hurt_face():
	match faction_id_manual:
		GameState.FACTIONS.SANDWICH_COOKIE:
			$"3DView/SubViewport/sandwich_cookie/HurtSprite".show()
			$"3DView/SubViewport/sandwich_cookie/AnimatedSprite3D".hide()
		GameState.FACTIONS.CHOCCY_CHIP:
			$"3DView/SubViewport/choccy/HurtSprite".show()
			$"3DView/SubViewport/choccy/AnimatedSprite3D".hide()
		GameState.FACTIONS.STRAWBRY_JAMMER:
			$"3DView/SubViewport/jammer/HurtSprite".show()
			$"3DView/SubViewport/jammer/AnimatedSprite3D".hide()
