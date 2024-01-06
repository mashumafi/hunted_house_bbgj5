class_name Possessable
extends Node

const SCARE_MULTI = 0.66
const SCARE_COST := 8

enum State {
	Default,
	Possessed,
}
var state := State.Default

@export var display_name: String

@export var camera: Camera3D

# area for triggering possession
@export var trigger_area: Area3D

# area for scaring targets
@export var scare_area: Area3D

@export var trigger_sound: AudioStreamPlayer3D

# affects the scare curve
@export var max_scare_distance := 2.0

# a curve for scare effectiveness based on distance
@export var scare_curve: Curve

@export var cooldown_sec := 1.0

var _can_scare := true

var possessions_since_last_investigation := 0
var interactions_since_last_investigation := 0

func _ready() -> void:
	if trigger_area:
		trigger_area.body_entered.connect(_body_entered)
		trigger_area.body_exited.connect(_body_exited)

func _body_entered(body: Node3D) -> void:
	ParanormalActivity.contact_made.emit(self, true)

func _body_exited(body: Node3D) -> void:
	ParanormalActivity.contact_made.emit(self, false)


func set_audio_effects_enabled(enabled: bool):
	var main_bus_index := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_effect_enabled(main_bus_index, 0, enabled)
	AudioServer.set_bus_effect_enabled(main_bus_index, 1, enabled)


func possess():
	if state != State.Default:
		printerr("Expected to be in the default state.")

	set_audio_effects_enabled(true)
	possessions_since_last_investigation += 1
	camera.current = true
	state = State.Possessed

func try_scare() -> bool:
	if HUD.energy_bar.value <= SCARE_COST:
		return false

	if not _can_scare:
		HUD.energy_bar.value -= SCARE_COST / 2.0 # Punish player if they scare too soon
		return false

	HUD.energy_bar.value -= SCARE_COST

	trigger_sound.play()
	_scare()
	for hunter: Node3D in scare_area.get_overlapping_bodies():  # TODO: Use the hunter type
		if not hunter.is_in_group("hunter"):
			continue

		var parent_node = get_parent()

		var space_state = parent_node.get_world_3d().direct_space_state

		var query = PhysicsRayQueryParameters3D.create(
			parent_node.global_position + Vector3(0, 0.25, 0),
			hunter.global_position + Vector3(0, 0.25, 0),
			0x1,  # 1 in hexadecimal for 1st collision layer (hunter + walls)
			[]) # determine if excluding collision of of possessable is needed
		var intersect = space_state.intersect_ray(query)
		var blocked : bool = not intersect.has("collider") or not intersect["collider"].is_in_group("hunter")

		var trigger_position := trigger_area.global_position
		var distance := hunter.global_position.distance_to(trigger_position)
		var distance_scaled : float = lerp(distance, max_scare_distance, .65) if blocked else distance
		hunter.scare(scare_curve.sample(remap(distance_scaled, 0, max_scare_distance, 0.0, 1.0))  * SCARE_MULTI, trigger_position)

	interactions_since_last_investigation += 1
	_can_scare = false
	get_tree().create_timer(cooldown_sec).timeout.connect(func(): _can_scare = true)

	if ParanormalActivity.investigations.has(self):
		return true

	ParanormalActivity.recently_interacted.erase(self)
	ParanormalActivity.recently_interacted.push_front(self)

	ParanormalActivity.interacted.emit(self)

	return true

func _scare() -> void:
	pass

func _process(delta: float) -> void:
	if state == State.Possessed:
		HUD.energy_bar.value -= delta * 3.5
		if HUD.energy_bar.value == 0.0:
			exit()
			return

		if Input.is_action_just_pressed("interact"):
			if not try_scare():
				pass

		if Input.get_vector("move_left", "move_right", "move_up", "move_down").length_squared() > 0:
			exit()
			return

func exit():
	state = State.Default
	set_audio_effects_enabled(false)
	var ghost : Node3D = get_tree().get_nodes_in_group("ghost")[0]
	ParanormalActivity.spawn_ghost(ghost, true)
	HUD.hide_vignette(.25)

func investigated() -> void:
	trigger_sound.play()
	possessions_since_last_investigation = 0
	interactions_since_last_investigation = 0
