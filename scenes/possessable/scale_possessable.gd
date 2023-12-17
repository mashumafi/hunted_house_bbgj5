class_name ScalePossessable
extends Possessable

# animation player to
@export var node: Node3D

@export var scale_factor := 1.1

func _scare() -> void:
	toggle()

func toggle():
	node.scale *= scale_factor

func investigated():
	super()
	node.scale = Vector3.ONE
