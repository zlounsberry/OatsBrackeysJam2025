extends Node2D

signal read_complete # to avoid race conditions...

const DIE = preload("res://scenes/die.tscn")

@export var attacker_player_id: int
@export var attacker_player_rolls_array: Array = []
@export var attacker_army_size: int
@export var defender_player_id: int
@export var defender_player_rolls_array: Array = []
@export var defender_army_size: int

func _ready() -> void:
	_throw_dice()


func reorder_dice(is_attacker: bool) -> void:
	var dice_counter: int = 0
	var number_to_roll: int = min(len(attacker_player_rolls_array), len(defender_player_rolls_array))
	if is_attacker:
		for attacker_roll in attacker_player_rolls_array:
			for dice in get_tree().get_nodes_in_group("dice"):
				if dice.player_id == attacker_player_id:
					if dice_counter > number_to_roll:
						dice.queue_free() # TODO: animate
					else:
						print("move this one up ", attacker_roll)
						dice.roll_position = dice_counter
						dice_counter += 1
	else:
		for defender_roll in defender_player_rolls_array:
			for dice in get_tree().get_nodes_in_group("dice"):
				if dice.player_id == defender_player_id:
					if dice_counter > number_to_roll:
						dice.queue_free() # TODO: animate
					else:
						print("move this one up ", defender_roll)
						dice.roll_position = dice_counter
						dice_counter += 1


func read_dice() -> void:
	var played_dice: Array = $"3DView/SubViewport/DiceReader".get_overlapping_areas()
	for die_area in played_dice:
		var die: RigidBody3D = die_area.get_parent()
		match die.player_id:
			attacker_player_id:
				attacker_player_rolls_array.append(die_area.face_value)
				die.roll_value = die_area.face_value
			defender_player_id:
				defender_player_rolls_array.append(die_area.face_value)
				die.roll_value = die_area.face_value
	attacker_player_rolls_array.sort()
	attacker_player_rolls_array.reverse()
	defender_player_rolls_array.sort()
	defender_player_rolls_array.reverse()
	print(attacker_player_rolls_array)
	print(defender_player_rolls_array)
	read_complete.emit()


func _throw_dice() -> void:
	for _value in range(attacker_army_size):
		var die: RigidBody3D = DIE.instantiate()
		die.is_attacking = true
		die.player_id = attacker_player_id
		die.faction_id = GameState.current_player_dict[attacker_player_id]["faction_id"]
		add_child(die)
		die.global_position = $"3DView/SubViewport/AttackerSpawn".global_position
	for _value in range(defender_army_size):
		var die: RigidBody3D = DIE.instantiate()
		die.is_attacking = false
		die.player_id = defender_player_id
		die.faction_id = GameState.current_player_dict[defender_player_id]["faction_id"]
		add_child(die)
		die.global_position = $"3DView/SubViewport/DefenderSpawn".global_position
	$ReadTimer.start()


func _on_read_timer_timeout() -> void:
	read_dice()
	await read_complete
	reorder_dice(true)
	reorder_dice(false)
