extends Node

var hunters_left = 0

func _ready():
	var hunters = get_tree().get_nodes_in_group("hunters")[0].get_children()
	hunters_left = hunters.size()
	for hunter in hunters:
		hunter.die.connect(process_death)

func pre_start(params):
	var cur_scene: Node = get_tree().current_scene
	print("Scene loaded: ", cur_scene.name, " (", cur_scene.scene_file_path, ")")
	ParanormalActivity.spawn_ghost($GhostSpawn)
	
	ParanormalActivity.end_game.connect(process_end_game)

func start():
	print("gameplay.gd: start() called")

func _process(delta: float) -> void:
	pass

func process_death():
	print("process death called")
	hunters_left -= 1
	if hunters_left <= 0:
		process_end_game(true, "Hunters were scared away!")

func process_end_game(win_lose: bool, reason: String):
	var params = {
		"show_progress_bar": false,
		"win_lose": win_lose,
		"reason": reason
	}
	Game.change_scene_to_file("res://scenes/menu/win_lose_screen.tscn", params)
