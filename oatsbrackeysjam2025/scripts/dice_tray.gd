extends Node2D

signal reorder_complete # to avoid race conditions...
signal movement_complete # to avoid race conditions...
signal deal_damage_to_army(
	attacker_army: Army, 
	attacker_tile: MapTile, 
	damage_to_attacker: int, 
	defender_army: Army, 
	defender_tile: MapTile, 
	damage_to_defender: int
) 

const DIE = preload("res://scenes/die.tscn")

@onready var damage_to_attacker: int = 0
@onready var damage_to_defender: int = 0
@onready var reorder_completed: bool = false
@onready var movement_completed: bool = false


@export var attacker_player_id: int
@export var attacker_army: Army
@export var attacker_player_rolls_array: Array = []
@export var attacker_army_size: int
@export var defender_player_id: int
@export var defender_army: Army
@export var defender_player_rolls_array: Array = []
@export var defender_army_size: int

var attacker_tile: MapTile
var defender_tile: MapTile


func _ready() -> void:
	$"3DView/SubViewport/Camera3D".make_current()
	self.reorder_complete.connect(_on_reorder_complete)
	self.movement_complete.connect(_on_movement_complete)
	_throw_dice()


func _compare_dice():
	var number_of_dice_rolled: int = min(len(attacker_player_rolls_array), len(defender_player_rolls_array))
#	 Use the first value in each sub-array within the attacker and defender arrays
	for array_position in range(number_of_dice_rolled):
		if attacker_player_rolls_array[array_position][0] < defender_player_rolls_array[array_position][0]:
			damage_to_attacker += 1
			attacker_player_rolls_array[array_position][1].queue_free()
		if attacker_player_rolls_array[array_position][0] > defender_player_rolls_array[array_position][0]:
			damage_to_defender += 1
			defender_player_rolls_array[array_position][1].queue_free()
	prints("dealing", damage_to_attacker, "to attacker and",damage_to_defender,"to defender")
	await get_tree().create_timer(1).timeout # DEBUG
	print(attacker_army, defender_army)
	deal_damage_to_army.emit(
		attacker_army,
		attacker_tile, 
		damage_to_attacker,
		defender_army,
		defender_tile, 
		damage_to_defender
	)
	self.queue_free()


func _move_dice(is_attacker: bool):
	var element_counter: int = 0 
	if is_attacker:
		for attacker_roll in attacker_player_rolls_array:
			var die = attacker_roll[1]
			await get_tree().process_frame
			if die == null:
				print("continuing!")
				continue
			die.get_node("CollisionShape3D").disabled = true
			die.freeze = true
			var tween: Tween = create_tween()
			prints(len(attacker_player_rolls_array), element_counter, get_node(str("3DView/SubViewport/FinalPositions/AttackerDie", element_counter)))
			tween.tween_property(die, "global_position", get_node(str("3DView/SubViewport/FinalPositions/AttackerDie", element_counter)).global_position, 0.1)
			element_counter += 1
			await tween.finished
	else:
		for defender_roll in defender_player_rolls_array:
			var die = defender_roll[1]
			await get_tree().process_frame
			if die == null:
				continue
			die.get_node("CollisionShape3D").disabled = true
			die.freeze = true
			var tween: Tween = create_tween()
			prints(len(defender_player_rolls_array), element_counter, get_node(str("3DView/SubViewport/FinalPositions/DefenderDie", element_counter)))
			tween.tween_property(die, "global_position", get_node(str("3DView/SubViewport/FinalPositions/DefenderDie", element_counter)).global_position, 0.1)
			element_counter += 1
			await tween.finished
	movement_complete.emit()
	movement_completed = true # Set this to avoid triggering multiple signals


func read_and_sort_dice() -> void:
	var tween: Tween = create_tween()
	tween.tween_property($"3DView/SubViewport/Chutes", "global_position:y", -2, 1.5)
	await tween.finished
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
	reorder_complete.emit()
	reorder_completed = true # Set this to avoid triggering multiple signals


func _throw_dice() -> void:
#	 Define the tiles to avoid the race condition that crashes game
	attacker_tile = attacker_army.currently_occupied_tile
	for value in range(attacker_army_size):
		var die: RigidBody3D = DIE.instantiate()
		die.is_attacking = true
		die.player_id = attacker_player_id
		die.faction_id = GameState.current_player_dict[attacker_player_id]["faction_id"]
		add_child(die)
		die.global_position = get_node(str("3DView/SubViewport/SpawnPositions/AttackerDie", value)).global_position
		await get_tree().create_timer(0.1).timeout

	defender_tile = defender_army.currently_occupied_tile
	for value in range(defender_army_size):
		var die: RigidBody3D = DIE.instantiate()
		die.is_attacking = false
		die.player_id = defender_player_id
		die.faction_id = GameState.current_player_dict[defender_player_id]["faction_id"]
		add_child(die)
		die.global_position = get_node(str("3DView/SubViewport/SpawnPositions/DefenderDie", value)).global_position
		await get_tree().create_timer(0.1).timeout
	$ReadTimer.start()


func _on_read_timer_timeout() -> void:
	read_and_sort_dice()


func _on_reorder_complete() -> void:
	if reorder_completed:
		return
	_move_dice(true)
	_move_dice(false)


func _on_movement_complete() -> void:
	if movement_completed:
		return
	await get_tree().create_timer(3).timeout
	_compare_dice()
