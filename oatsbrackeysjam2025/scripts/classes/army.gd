extends Node3D
class_name Army

const SANDWICH_COOKIE_MODEL = preload("res://scenes/armies/sandwich_cookie_model.tscn")
const CHOCCY_MODEL = preload("res://scenes/armies/choccy_model.tscn")
const JAMMER_MODEL = preload("res://scenes/armies/jammer_model.tscn")

signal movement_complete

@export var is_ai: bool = false
@export var currently_taking_turn: bool = false
@export var currently_occupied_tile: MapTile
@export var controlling_player_id: int
@export var faction_id: int = 0
@export var army_size: int = 0


func _ready() -> void:
	add_to_group("army")


func select_this_army() -> void:
	for army_child: Army in get_tree().get_nodes_in_group("army"):
		army_child.currently_taking_turn = false
		army_child.get_node("TurnIndicator").hide()
	currently_taking_turn = true
	GameState.current_selected_army = self
	$TurnIndicator.show()


func update_army_size_visuals() -> void:
	if army_size <= 0:
		return
	for child in $ArmyVisuals.get_children():
		child.hide()
	get_node(str("ArmyVisuals/", army_size)).show()
	$DEBUG.text = str("Player ", controlling_player_id)


func move_to_new_space(current_tile: MapTile, new_tile: MapTile, unit_count: int) -> void:
	if not currently_taking_turn:
		return
	if current_tile == null:
		prints("no current tile!", currently_occupied_tile)
		return
	if new_tile == null:
		print("no new tile!")
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
			GameState.FACTIONS.CHOCCY_CHIP:
				model_scene = CHOCCY_MODEL.instantiate() 
				add_child(model_scene)
			GameState.FACTIONS.STRAWBRY_JAMMER:
				model_scene = JAMMER_MODEL.instantiate()
				add_child(model_scene)
				
		var htween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
		htween.tween_property(model_scene, "global_position:z", new_position.z, 0.25)
		htween.tween_property(model_scene, "global_position:x", new_position.x, 0.25)
		var vtween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(false)
		vtween.tween_property(model_scene, "global_position:y", 3, 0.125)
		vtween.tween_property(model_scene, "global_position:y", new_position.y, 0.125)
		await htween.finished
		if not first_model_down:
			first_model_down = true
			new_tile.update_ownership(true, self) # I don't love doing this in this scene, but beats managing a bunch of signals and awaits I think?
			currently_occupied_tile = new_tile
		model_scene.queue_free()
	army_size -= unit_count
	current_tile.update_ownership(false, null) # I don't love doing this in this scene, but beats managing a bunch of signals and awaits I think?
	movement_complete.emit()
	GameState.update_state(GameState.STATE_MACHINE.SELECTING_IN_GAME)
	if army_size <= 0: 
		var current_army_array: Array = GameState.current_player_dict[GameState.current_player_turn]["current_armies"]
		var army_position: int = current_army_array.find(self)
		prints("player game state:", GameState.current_player_turn, "player army: ", controlling_player_id)
		print(GameState.current_player_dict[GameState.current_player_turn])
		GameState.current_player_dict[GameState.current_player_turn]["current_armies"].pop_at(army_position)
		print("removed army: ", GameState.current_player_dict[GameState.current_player_turn])
		self.queue_free()
	update_army_size_visuals()
