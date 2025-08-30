extends Node3D

func _process(delta: float) -> void:
	$Marker3D.rotation.y += delta / 6
