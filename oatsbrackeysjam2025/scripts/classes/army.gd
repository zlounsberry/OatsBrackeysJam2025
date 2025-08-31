extends Node3D
class_name Army

const SANDWICH_COOKIE_MODEL = preload("res://scenes/armies/sandwich_cookie_model.tscn")
const CHOCCY_MODEL = preload("res://scenes/armies/choccy_model.tscn")
const JAMMER_MODEL = preload("res://scenes/armies/jammer_model.tscn")

signal movement_complete
signal selected_next_army
signal ai_player_confirmed(unit_count: int, is_attack: bool, self_id: Army, new_tile: MapTile)
signal remove_army(self_id: Army)

@export var is_ai: bool = false
@export var currently_taking_turn: bool = false
@export var currently_occupied_tile: MapTile
@export var controlling_player_id: int
@export var faction_id: int = 0
@export var army_size: int = 0
@export var army_id: int = 0

var max_army_size: int


func _ready() -> void:
	add_to_group("army")
	max_army_size = GameState.MAX_ARMY_SIZE
	print("is_ai ", is_ai)


func _process(_delta: float) -> void:
	$DEBUG.text = str(currently_occupied_tile.name, " ", army_size)


func select_this_army() -> void:
	for army_child: Army in get_tree().get_nodes_in_group("army"):
		army_child.currently_taking_turn = false
		army_child.get_node("TurnIndicator").hide()
	currently_taking_turn = true
	GameState.current_selected_army = self
	$TurnIndicator.show()
	#if is_ai:
		#_move_ai()


func update_army_size_visuals() -> void:
	if army_size <= 0:
		return
	for child in $ArmyVisuals.get_children():
		child.hide()
	get_node(str("ArmyVisuals/", army_size)).show()


func add_units_to_army() -> void:
	if army_size <= max_army_size:
		army_size += 1
	for continent in GameState.current_continent_control_dict.keys():
		if GameState.current_continent_control_dict[continent]["controlling_player"] == controlling_player_id:
			if (army_size + GameState.current_continent_control_dict[continent]["continent_bonus"]) <= max_army_size:
				prints("adding continent bonus for",controlling_player_id)
				army_size += GameState.current_continent_control_dict[continent]["continent_bonus"]
			else:
				army_size = max_army_size
			prints("player", controlling_player_id, "gets an extra for controlling continent", continent)
		else:
			#prints("\n\n\nno player owns: ", continent, "see?")
			prints(GameState.current_continent_control_dict)
	update_army_size_visuals()


func move_to_new_space(current_tile: MapTile, new_tile: MapTile, unit_count: int) -> void:
	_move_models(current_tile, new_tile, unit_count)
	await movement_complete
	prints("got here move complete", current_tile, new_tile, unit_count)
	currently_occupied_tile.remove_army_units_from_tile(unit_count)
	#update_army_size_visuals()
	GameState.update_state(GameState.STATE_MACHINE.SELECTING_IN_GAME)


func remove_self() -> void:
	print("removing army from army script")
	selected_next_army.emit()
	remove_army.emit(self)


func _move_models(current_tile: MapTile, new_tile: MapTile, unit_count: int) -> void: 
	if not currently_taking_turn:
		return
	if current_tile == null:
		#prints("no current tile!", currently_occupied_tile)
		return
	if new_tile == null:
		#print("no new tile!")
		return
	GameState.update_state(GameState.STATE_MACHINE.TRANSITIONING)
	var model_scene: Node3D
	var first_model_down: bool = false
	var new_position: Vector3 = new_tile.get_node("Marker3D").global_position
	for _value in unit_count:
		match faction_id:
			GameState.FACTIONS.SANDWICH_COOKIE:
				model_scene = SANDWICH_COOKIE_MODEL.instantiate()
				add_child(model_scene)
				model_scene.add_to_group("delete_me")
			GameState.FACTIONS.CHOCCY_CHIP:
				model_scene = CHOCCY_MODEL.instantiate() 
				add_child(model_scene)
				model_scene.add_to_group("delete_me")
			GameState.FACTIONS.STRAWBRY_JAMMER:
				model_scene = JAMMER_MODEL.instantiate()
				add_child(model_scene)
				model_scene.add_to_group("delete_me")
		_play_boing()
		var htween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
		htween.tween_property(model_scene, "global_position:z", new_position.z, 0.25)
		htween.tween_property(model_scene, "global_position:x", new_position.x, 0.25)
		var vtween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(false)
		vtween.tween_property(model_scene, "global_position:y", 3, 0.125)
		vtween.tween_property(model_scene, "global_position:y", new_position.y, 0.125)
		await htween.finished
	for model in get_tree().get_nodes_in_group("delete_me"):
		model.queue_free()
	movement_complete.emit()


func _play_boing() -> void:
	get_node("Boing").play()


#func _move_ai() -> void:
	#print("moving ai")
	#var current_tile_array: Array = []
	#var select_next_army: bool = false
	#for map_id in GameState.TILE_ADJACENT_MAP_DICT[currently_occupied_tile.tile_id]:
		#for map_tile: MapTile in get_tree().get_nodes_in_group("map_tile"):
			#if map_id == map_tile.tile_id:
				#current_tile_array.append(map_tile)
	#print(current_tile_array)
	#current_tile_array.shuffle()
	##for current_tile_element in current_tile_array:
		##if current_tile_element == current_tile_array[-1]:
			##selected_next_army.emit()
			##return
	#for current_tile_element in current_tile_array:
		#if current_tile_element == current_tile_array[-1]:
			#select_next_army = true
			#prints("Breaking loop", current_tile_element, current_tile_array)
		#var potential_tile: MapTile = current_tile_array.pop_front()
		#prints("potential_tile", potential_tile, typeof(potential_tile))
		#if not potential_tile.is_occupied:
			#if army_size <= 1:
				#print("emit signal 1")
				#ai_player_confirmed.emit(army_size, false, self, potential_tile)
			#else:
				#print("emit signal 2")
				#ai_player_confirmed.emit(army_size - 1, false, self, potential_tile)
			#return
		#else:
			#if potential_tile.occupying_army.controlling_player_id == GameState.current_player_turn:
				#print("tile is occupied by self")
				#continue
			#else:
				#if army_size <= 1:
					#print("emit signal 3")
					#ai_player_confirmed.emit(army_size, true, self, potential_tile)
				#else:
					#print("emit signal 4")
					#ai_player_confirmed.emit(army_size, true, self, potential_tile)
		#if select_next_army:
			#print("select next army")
			#selected_next_army.emit()
