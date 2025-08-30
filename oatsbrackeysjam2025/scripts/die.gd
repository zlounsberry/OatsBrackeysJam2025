extends RigidBody3D

const CC = preload("res://assets/resources/textures/CC.tres")
const SCC = preload("res://assets/resources/textures/SCC.tres")
const SJ = preload("res://assets/resources/textures/SJ.tres")
const OUTLINE_MATERIAL = preload("res://assets/resources/textures/outline_material.tres")
const IMPULSE_STRENGTH = 3

@export var faction_id: int
@export var player_id: int 
@export var is_attacking: bool
@export var roll_value: int


func _ready() -> void:
	rotation_degrees.x = randf_range(0, 360)
	rotation_degrees.y = randf_range(0, 360)
	rotation_degrees.z = randf_range(0, 360)
	skin_self()
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
		#print("is attacking")
		match faction_id:
			GameState.FACTIONS.SANDWICH_COOKIE:
				$Cube.set_surface_override_material(0, SCC)
				$Cube.set_surface_override_material(1, OUTLINE_MATERIAL)
			GameState.FACTIONS.CHOCCY_CHIP:
				$Cube.set_surface_override_material(0, CC)
				$Cube.set_surface_override_material(1, OUTLINE_MATERIAL)
			GameState.FACTIONS.STRAWBRY_JAMMER:
				$Cube.set_surface_override_material(0, SJ)
				$Cube.set_surface_override_material(1, OUTLINE_MATERIAL)


func destroy_self() -> void:
	print("destroying ", self)
	freeze = false
	if is_attacking:
		apply_central_impulse((Vector3.UP / 2 + Vector3.LEFT) * IMPULSE_STRENGTH * 3)
	else:
		apply_central_impulse((Vector3.UP / 2 + Vector3.RIGHT) * IMPULSE_STRENGTH * 3)
	var random_float_x: float = randf_range(1, 3)
	var random_float_y: float = randf_range(1, 3)
	var random_float_z: float = randf_range(1, 3)
	angular_velocity = Vector3(random_float_x, random_float_y, random_float_z)
	$Destroy.start()


func _on_destroy_timeout() -> void:
	print("queue free", self)
	queue_free()
