extends MeshInstance3D
class_name MapTile

@onready var is_hovered: bool = false


func _ready() -> void:
	$StaticBody3D.mouse_entered.connect(_show_outline)
	$StaticBody3D.mouse_exited.connect(_hide_outline)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		if is_hovered:
			prints(self, "is hovered")


func _show_outline():
	is_hovered = true
	$MeshInstance3D.show()


func _hide_outline():
	is_hovered = false
	$MeshInstance3D.hide()
