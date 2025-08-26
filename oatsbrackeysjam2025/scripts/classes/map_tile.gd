extends MeshInstance3D
class_name MapTile

signal clicked_this_tile(tile_position: Vector3)

@onready var is_hovered: bool = false
@onready var owned_faction: int = -99


func _ready() -> void:
	$StaticBody3D.mouse_entered.connect(_show_outline)
	$StaticBody3D.mouse_exited.connect(_hide_outline)


func _input(event: InputEvent) -> void:
	if GameState.STATE_MACHINE.DISABLED:
		return
	if event.is_action_pressed("left_click"):
		if is_hovered:
			prints(self, "is hovered")
			clicked_this_tile.emit($Marker3D.global_position)


func update_owned_faction(faction_id: int) -> void:
	owned_faction = faction_id


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
