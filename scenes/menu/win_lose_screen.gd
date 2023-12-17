extends Control

@export var winplayer : AudioStreamPlayer
@export var loseplayer : AudioStreamPlayer

@export var Title : Label
@export var Reason : Label

var win: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	HUD.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func pre_start(params):
	win = params["win_lose"]
	if not params["win_lose"]:
		Title.text = "You Lose..."
		Reason.text = params["reason"]

func start():
	if win:
		winplayer.play()
	else:
		loseplayer.play()

func _on_replay_button_pressed():
	var params = {
		"show_progress_bar": true,
		"a_number": 10,
		"a_string": "Ciao!",
		"an_array": [1, 2, 3, 4],
		"a_dict": {
			"name": "test",
			"val": 15
		},
	}
	Game.change_scene_to_file("res://scenes/gameplay/gameplay.tscn", params)


func _on_menu_button_pressed():
	Game.change_scene_to_file("res://scenes/menu/menu.tscn")
