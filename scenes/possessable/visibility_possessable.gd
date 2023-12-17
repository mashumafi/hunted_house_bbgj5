# Possession of visibility controlled items
class_name VisibilityPossessable
extends Possessable

# animation player to
@export var nodes: Array[Node3D]

func _scare() -> void:
	toggle()

func toggle():
	for node: Node3D in nodes:
		if node is GPUParticles3D and OS.has_feature("web"):
			continue

		node.visible = not node.visible

func investigated():
	super()
	if nodes.size() > 0 and not nodes[0].visible:
		toggle()
