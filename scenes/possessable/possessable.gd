class_name Possessable
extends Node

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

# affects the scare curve
@export var max_scare_distance := 1

# a curve for scare effectiveness based on distance
@export var scare_curve: Curve

@export var cooldown_sec := 1

var _can_scare := true

var possessions_since_last_investigation := 0
var interactions_since_last_investigation := 0

func _ready() -> void:
	trigger_area.body_entered.connect(_body_entered)
	trigger_area.body_exited.connect(_body_exited)

func _body_entered(body: Node3D) -> void:
	ParanormalActivity.contact_made.emit(self, true)

func _body_exited(body: Node3D) -> void:
	ParanormalActivity.contact_made.emit(self, false)

func possess():
	if state != State.Default:
		printerr("Expected to be in the default state.")

	possessions_since_last_investigation += 1
	camera.current = true
	state = State.Possessed

func try_scare() -> bool:
	# TODO: Check ghost energy and consume it before trying to scare
	if not _can_scare:
		return false

	_scare()
	for hunter: Node3D in scare_area.get_overlapping_bodies():  # TODO: Use the hunter type
		var trigger_position := trigger_area.global_position
		var distance := hunter.global_position.distance_to(trigger_position)
		hunter.scare(scare_curve.sample(remap(distance, 0, max_scare_distance, 0.0, 1.0)), trigger_position)

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
		if Input.is_action_just_pressed("interact"):
			try_scare()
		if Input.get_vector("move_left", "move_right", "move_up", "move_down").length_squared() > 0:
			state = State.Default
			var ghost : Node3D = get_tree().get_nodes_in_group("ghost")[0]
			ParanormalActivity.spawn_ghost(ghost)

func investigated() -> void:
	possessions_since_last_investigation = 0
	interactions_since_last_investigation = 0
