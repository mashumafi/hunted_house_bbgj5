extends CanvasLayer

@onready var health_bar : ProgressBar = %HealthProgressBar
@onready var energy_bar : ProgressBar = %EnergyProgressBar
@onready var timer_label : Label = %TimerLabel

@onready var vignette := $Control/Vignette as ColorRect
@onready var vignette_mat : ShaderMaterial = vignette.material.duplicate()

var FIVE_MINUTES := 60.0 * 5.0
var time_left := 0.0

func _ready() -> void:
	vignette.material = vignette_mat
	hide()
	ParanormalActivity.end_game.connect(func(win: bool, reason: String): hide())
	visibility_changed.connect(func() -> void:
		if visible:
			health_bar.value = 100
			energy_bar.value = 100
			time_left = FIVE_MINUTES
	)

	visibility_changed.connect(func():
		hide_vignette()
	)

	health_bar.value_changed.connect(func(value: float) -> void:
		if value == 0:
			ParanormalActivity.end_game.emit(false, "You died.")
	)

func _process(delta: float) -> void:
	time_left = max(time_left - delta, 0.0)
	if time_left == 0.0:
		ParanormalActivity.end_game.emit(false, "You ran out of time.")

	timer_label.text = get_time_formatted(time_left)
	
func get_time_formatted(time_left: float) -> String:
	var seconds = fmod(time_left, 60)
	var minutes = fmod(time_left, 3600) / 60
	return "%01d:%02d" % [minutes, seconds]
	

func show_vignette(duration: float = 1.0) -> void:
	create_tween().tween_method(set_vignette_intensity, get_vignette_intensity(), .4, duration)

func hide_vignette(duration: float = 1.0) -> void:
	create_tween() \
		.tween_method(set_vignette_intensity, get_vignette_intensity(), .0, duration) \
		. set_ease(Tween.EASE_OUT)

func set_vignette_intensity(intensity: float) -> void:
	vignette_mat.set_shader_parameter("vignette_intensity", intensity)

func get_vignette_intensity() -> float:
	return vignette_mat.get_shader_parameter("vignette_intensity")
