extends Node2D

signal read_complete # to avoid race conditions...
signal reorder_complete # to avoid race conditions...
signal movement_complete # to avoid race conditions...
signal deal_damage_to_army(is_defender: bool, damage_value: int) # to avoid race conditions...

const DIE = preload("res://scenes/die.tscn")

@onready var damage_to_attacker: int = 0
@onready var damage_to_defender: int = 0
@onready var read_completed: bool = false
@onready var reorder_completed: bool = false
@onready var movement_completed: bool = false


@export var attacker_player_id: int
@export var attacker_player_rolls_array: Array = []
@export var attacker_army_size: int
@export var defender_player_id: int
@export var defender_player_rolls_array: Array = []
@export var defender_army_size: int


func _ready() -> void:
	self.read_complete.connect(_on_read_complete)
	self.reorder_complete.connect(_on_reorder_complete)
	self.movement_complete.connect(_on_movement_complete)
	_throw_dice()


func _compare_dice():
	var number_of_dice_rolled: int = min(len(attacker_player_rolls_array), len(defender_player_rolls_array))
#	 Use the first value in each sub-array within the attacker and defender arrays
	for array_position in range(number_of_dice_rolled):
		print("array position:", array_position)
		if attacker_player_rolls_array[array_position][0] < defender_player_rolls_array[array_position][0]:
			damage_to_attacker += 1
			attacker_player_rolls_array[array_position][1].queue_free()
		if attacker_player_rolls_array[array_position][0] > defender_player_rolls_array[array_position][0]:
			damage_to_defender += 1
			defender_player_rolls_array[array_position][1].queue_free()
	deal_damage_to_army.emit(damage_to_attacker, damage_to_defender)
	prints("dealing", damage_to_attacker, "to attacker and",damage_to_defender,"to defender")


func _move_dice(is_attacker: bool):
	if is_attacker:
		for attacker_roll in attacker_player_rolls_array:
			var die = attacker_roll[1]
			if die == null:
				continue
			die.get_node("CollisionShape3D").disabled = true
			die.freeze = true
			var tween: Tween = create_tween()
			tween.tween_property(die, "global_position", get_node(str("3DView/SubViewport/AttackerDie", die.roll_position)).global_position, 0.25)
			await get_tree().create_timer(0.2).timeout
	else:
		for defender_roll in defender_player_rolls_array:
			var die = defender_roll[1]
			if die == null:
				continue
			die.get_node("CollisionShape3D").disabled = true
			die.freeze = true
			var tween: Tween = create_tween()
			tween.tween_property(die, "global_position", get_node(str("3DView/SubViewport/DefenderDie", die.roll_position)).global_position, 0.25)
			await get_tree().create_timer(0.2).timeout
	movement_complete.emit()
	movement_completed = true # Set this to avoid triggering multiple signals


func reorder_dice(is_attacker: bool) -> void:
	var dice_counter: int = 0
	var number_to_roll: int = min(len(attacker_player_rolls_array), len(defender_player_rolls_array))
#	 attacker_player_rolls_array is an array of arrays where the 1st position determines order and the 2nd position is the scene itself
	if is_attacker:
		for attacker_roll in attacker_player_rolls_array:
			if dice_counter >= number_to_roll:
				attacker_player_rolls_array.remove_at(attacker_player_rolls_array.find(attacker_roll))
				attacker_roll[1].queue_free() # TODO: animate
			else:
				attacker_roll[1].roll_position = dice_counter
				dice_counter += 1
	else:
		for defender_roll in defender_player_rolls_array:
			if dice_counter >= number_to_roll:
				defender_player_rolls_array.remove_at(defender_player_rolls_array.find(defender_roll))
				defender_roll[1].queue_free() # TODO: animate
			else:
				defender_roll[1].roll_position = dice_counter
				dice_counter += 1
	reorder_complete.emit()
	reorder_completed = true # Set this to avoid triggering multiple signals


func read_dice() -> void:
	var played_dice: Array = $"3DView/SubViewport/DiceReader".get_overlapping_areas()
	for die_area in played_dice:
		var die: RigidBody3D = die_area.get_parent()
		match die.player_id:
			attacker_player_id:
				attacker_player_rolls_array.append([die_area.face_value, die])
				die.roll_value = die_area.face_value
			defender_player_id:
				defender_player_rolls_array.append([die_area.face_value, die])
				die.roll_value = die_area.face_value
	attacker_player_rolls_array.sort()
	attacker_player_rolls_array.reverse()
	defender_player_rolls_array.sort()
	defender_player_rolls_array.reverse()
	print(attacker_player_rolls_array)
	print(defender_player_rolls_array)
	read_complete.emit()
	read_completed = true # Set this to avoid triggering multiple signals


func _throw_dice() -> void:
	for _value in range(attacker_army_size):
		var die: RigidBody3D = DIE.instantiate()
		die.is_attacking = true
		die.player_id = attacker_player_id
		die.faction_id = GameState.current_player_dict[attacker_player_id]["faction_id"]
		die.impulse_direction = $"3DView/SubViewport/AttackerSpawn".global_position.direction_to($"3DView/SubViewport/AttackerSpawn/AimHere".global_position)
		$"3DView/SubViewport/AttackerSpawn".rotate_y(deg_to_rad(-160 / attacker_army_size))
		add_child(die)
		die.global_position = $"3DView/SubViewport/AttackerSpawn".global_position
		await get_tree().create_timer(0.25).timeout

	for _value in range(defender_army_size):
		var die: RigidBody3D = DIE.instantiate()
		die.is_attacking = false
		die.player_id = defender_player_id
		die.faction_id = GameState.current_player_dict[defender_player_id]["faction_id"]
		die.impulse_direction = $"3DView/SubViewport/DefenderSpawn".global_position.direction_to($"3DView/SubViewport/DefenderSpawn/AimHere".global_position)
		$"3DView/SubViewport/DefenderSpawn".rotate_y(deg_to_rad(-160 / defender_army_size))
		add_child(die)
		die.global_position = $"3DView/SubViewport/DefenderSpawn".global_position
		await get_tree().create_timer(0.5).timeout

	$ReadTimer.start()


func _on_read_timer_timeout() -> void:
	read_dice()


func _on_read_complete() -> void:
	if read_completed:
		return
	reorder_dice(true)
	reorder_dice(false)


func _on_reorder_complete() -> void:
	if reorder_completed:
		return
	_move_dice(true)
	_move_dice(false)


func _on_movement_complete() -> void:
	if movement_completed:
		return
	await get_tree().create_timer(2).timeout
	_compare_dice()
