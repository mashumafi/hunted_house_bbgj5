# Possession of fire
class_name ParticlesPossessable
extends Possessable

# animation player to
@export var fire: Array[GPUParticles3D]

func _scare() -> void:
	toggle()

func toggle():
	for particle: GPUParticles3D in fire:
		particle.visible = not particle.visible

func investigated():
	super()
	if fire.size() > 0 and not fire[0].visible:
		toggle()
