extends Node3D
class_name Army

const SANDWICH_COOKIE_MODEL = preload("res://scenes/armies/sandwich_cookie_model.tscn")
const CHOCCY_MODEL = preload("res://scenes/armies/choccy_model.tscn")
const JAMMER_MODEL = preload("res://scenes/armies/jammer_model.tscn")

signal movement_complete
#signal army_defeated(is_defeated: bool)

@export var is_ai: bool = false
@export var currently_taking_turn: bool = false
@export var currently_occupied_tile: MapTile
@export var controlling_player_id: int
@export var faction_id: int = 0
@export var army_size: int = 0
@export var army_id: int = 0


func _ready() -> void:
	add_to_group("army")


func _process(_delta: float) -> void:
	$DEBUG.text = str(currently_occupied_tile.name, " ", army_size)


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


func _evaluate_if_army_needs_removing_from_current_tile() -> bool:
	print("Army size _evaluate_if_army_needs_removing_from_current_tile:", army_size)
	if army_size <= 0: 
		print("remove army _evaluate_if_army_needs_removing_from_current_tile()")
		return true
	return false


func move_to_new_space(current_tile: MapTile, new_tile: MapTile, unit_count: int) -> void:
	_move_models(current_tile, new_tile, unit_count)
	await movement_complete
	print("got here")
	var remove_from_tile: bool = _evaluate_if_army_needs_removing_from_current_tile()
	if remove_from_tile:
		print("Update ownership from move_to_new_space() in army.gd because army size is <= 0")
		current_tile.update_ownership(false, null)
		self.queue_free()
	update_army_size_visuals()
	GameState.update_state(GameState.STATE_MACHINE.SELECTING_IN_GAME)


func _move_models(current_tile: MapTile, new_tile: MapTile, unit_count: int) -> void: 
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
		prints(self, "currently occupied 1:", currently_occupied_tile)
		if not first_model_down:
			first_model_down = true
			#currently_occupied_tile = new_tile
	army_size -= unit_count
	print("Army size: ",army_size)
	movement_complete.emit()
