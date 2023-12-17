# Possession of fire
class_name FirePossessable
extends Possessable

# animation player to
@export var fire: Fire3D

func _scare() -> void:
	toggle()

func toggle():
	fire.visible = not fire.visible
