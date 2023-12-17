# Possession of doors
class_name DoorPossessable
extends Possessable

# animation player to
@export var door: Node3D

var opened := false

func _scare() -> void:
	toggle()

func toggle():
	opened = not opened
	if opened:
		create_tween().tween_property(door, "rotation", Vector3(0, PI / 2, 0), .5)
	else:
		create_tween().tween_property(door, "rotation", Vector3(0, 0, 0), .5)
		
func investigated() -> void:
	super()
	if not opened:
		toggle()
