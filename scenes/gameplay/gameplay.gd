extends Node

func pre_start(params):
	var cur_scene: Node = get_tree().current_scene
	print("Scene loaded: ", cur_scene.name, " (", cur_scene.scene_file_path, ")")
	ParanormalActivity.spawn_ghost($GhostSpawn)

func start():
	print("gameplay.gd: start() called")

func _process(delta: float) -> void:
	pass
