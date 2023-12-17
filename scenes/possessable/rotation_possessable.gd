# Possession of rotatable items
class_name RotationPossessable
extends Possessable

# animation player to
@export var target: Node3D

@export var target_rotation : Vector3

var opened := false

func _scare() -> void:
	toggle()

func toggle():
	opened = not opened
	if opened:
		create_tween().tween_property(target, "rotation", target_rotation, .5)
	else:
		create_tween().tween_property(target, "rotation", Vector3(0, 0, 0), .5)

func investigated() -> void:
	super()
	if not opened:
		toggle()
