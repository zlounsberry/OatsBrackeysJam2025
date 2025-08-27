extends MeshInstance3D
class_name MapTile

signal clicked_this_tile(self_id: MapTile)

@onready var is_hovered: bool = false

@export var continent_id: int = 0
@export var current_owner: int = 0

var is_occupied: bool = false
var occupying_army: Army


func _ready() -> void:
	add_to_group("map_tile")
	$StaticBody3D.mouse_entered.connect(_show_outline)
	$StaticBody3D.mouse_exited.connect(_hide_outline)


func _input(event: InputEvent) -> void:
	if GameState.STATE_MACHINE.DISABLED:
		return
	if event.is_action_pressed("left_click"):
		if is_hovered:
			clicked_this_tile.emit(self)


func remove_army_units_from_tile(army_scene: Army, unit_count: int):
	army_scene.army_size -= unit_count

	if army_scene.army_size <= 0:
		update_ownership(false , army_scene)
		army_scene.queue_free()
	


func update_ownership(is_occupied: bool, army_scene: Army) -> void:
	if is_occupied:
		occupying_army = army_scene
		is_occupied = false
	else:
		occupying_army = army_scene
		is_occupied = true
	
		


func _show_outline():
	if GameState.STATE_MACHINE.DISABLED:
		return
	is_hovered = true
	$MeshInstance3D.show()


func _hide_outline():
	if GameState.STATE_MACHINE.DISABLED:
		return
	is_hovered = false
	$MeshInstance3D.hide()
