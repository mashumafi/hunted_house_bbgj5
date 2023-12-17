# Possession of lights
class_name LightPossessable
extends Possessable

# animation player to
@export var light: Light3D

func _scare() -> void:
	toggle()

func toggle():
	light.visible = not light.visible
