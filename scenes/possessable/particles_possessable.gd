# Possession of fire
class_name FirePossessable
extends Possessable

# animation player to
@export var fire: Array[GPUParticles3D]

func _scare() -> void:
	toggle()

func toggle():
	for particle: GPUParticles3D in fire:
		particle.visible = not particle.visible
