extends Node

func pre_start(params):
	var cur_scene: Node = get_tree().current_scene
	print("Scene loaded: ", cur_scene.name, " (", cur_scene.scene_file_path, ")")
	ParanormalActivity.spawn_ghost($GhostSpawn)

	ParanormalActivity.end_game.connect(process_end_game)

func start():
	print("gameplay.gd: start() called")

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var hunters_parent = get_tree().get_nodes_in_group("hunters")[0]
	if hunters_parent.get_children().size() == 0:
		process_end_game(true, "Hunters were scared away!")


func process_end_game(win_lose: bool, reason: String):
	var params = {
		"show_progress_bar": false,
		"win_lose": win_lose,
		"reason": reason
	}
	Game.change_scene_to_file("res://scenes/menu/win_lose_screen.tscn", params)
