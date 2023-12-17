extends CanvasLayer

@onready var health_bar : ProgressBar = %HealthProgressBar
@onready var energy_bar : ProgressBar = %EnergyProgressBar
@onready var timer_label : Label = %TimerLabel

var FIVE_MINUTES := 60.0 * 5.0
var time_left := 0.0

func _ready() -> void:
	hide()
	ParanormalActivity.end_game.connect(func(win: bool, reason: String): hide())
	visibility_changed.connect(func() -> void:
		if visible:
			health_bar.value = 100
			energy_bar.value = 100
			time_left = FIVE_MINUTES
	)

	health_bar.value_changed.connect(func(value: float) -> void:
		if value == 0:
			ParanormalActivity.end_game.emit(false, "You died.")
	)

func _process(delta: float) -> void:
	time_left = max(time_left - delta, 0.0)
	if time_left == 0.0:
		ParanormalActivity.end_game.emit(false, "You ran out of time.")

	timer_label.text = String.num_int64(time_left)
