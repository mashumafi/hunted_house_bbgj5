extends Control

@onready var volumn_slider : HSlider = %VolumeSlider

func _ready():
	HUD.hide()
	# needed for gamepads to work
	$VBoxContainer/PlayButton.grab_focus()
	if OS.has_feature('HTML5'):
		$VBoxContainer/ExitButton.queue_free() # exit button dosn't make sense on HTML5

	var main_bus_index := AudioServer.get_bus_index("Master")
	volumn_slider.value = db_to_linear(AudioServer.get_bus_volume_db(main_bus_index))
	volumn_slider.value_changed.connect(func(volume):
		AudioServer.set_bus_volume_db(main_bus_index, linear_to_db(volume))
	)

	var developers := [
		"Matthew Murphy",
		"Peyton Williams",
	]
	developers.shuffle()
	for developer: String in developers:
		var label := Label.new()
		label.text = developer
		$Credits.add_child(label)


func _on_PlayButton_pressed() -> void:
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


func _on_ExitButton_pressed() -> void:
	# gently shutdown the game
	var transitions = get_node_or_null("/root/Transitions")
	if transitions:
		transitions.fade_in({
			'show_progress_bar': false
		})
		await transitions.anim.animation_finished
		await get_tree().create_timer(0.3).timeout
	get_tree().quit()
