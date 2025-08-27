extends RigidBody3D

const CC = preload("res://assets/resources/CC.tres")
const SCC = preload("res://assets/resources/SCC.tres")
const SJ = preload("res://assets/resources/SJ.tres")
const OUTLINE_MATERIAL = preload("res://assets/resources/outline_material.tres")
const IMPULSE_STRENGTH = 3

@export var faction_id: int
@export var player_id: int 
@export var is_attacking: bool
@export var roll_value: int


func _ready() -> void:
	rotation_degrees.x = randf_range(0, 360)
	rotation_degrees.y = randf_range(0, 360)
	rotation_degrees.z = randf_range(0, 360)
	_toss_self()


func _toss_self() -> void:
	if is_attacking:
		apply_central_impulse((Vector3.UP / 2 + Vector3.RIGHT) * IMPULSE_STRENGTH)
	else:
		apply_central_impulse((Vector3.UP / 2 + Vector3.LEFT) * IMPULSE_STRENGTH)
	var random_float_x: float = randf_range(1, 3)
	var random_float_y: float = randf_range(1, 3)
	var random_float_z: float = randf_range(1, 3)
	angular_velocity = Vector3(random_float_x, random_float_y, random_float_z)


func skin_self() -> void:
	if is_attacking:
		print("attacker! need new skin!")
	match faction_id:
		GameState.FACTIONS.SANDWICH_COOKIE:
			$RigidBody3D/Cube.set_surface_override_material(0, SCC)
			$RigidBody3D/Cube.set_surface_override_material(0, OUTLINE_MATERIAL)
		GameState.FACTIONS.CHOCCY_CHIP:
			$RigidBody3D/Cube.set_surface_override_material(0, CC)
			$RigidBody3D/Cube.set_surface_override_material(0, OUTLINE_MATERIAL)
		GameState.FACTIONS.STRAWBRY_JAMMER:
			$RigidBody3D/Cube.set_surface_override_material(0, SJ)
			$RigidBody3D/Cube.set_surface_override_material(0, OUTLINE_MATERIAL)
