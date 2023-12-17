extends CanvasLayer

@onready var health_bar : ProgressBar = %HealthProgressBar
@onready var energy_bar : ProgressBar = %EnergyProgressBar

func _ready() -> void:
	hide()
	visibility_changed.connect(func() -> void:
		if visible:
			health_bar.value = 100
			energy_bar.value = 100
	)

	health_bar.value_changed.connect(func(value: float) -> void:
		if value == 0:
			hide()
			ParanormalActivity.end_game.emit(false, "You died.")
	)
