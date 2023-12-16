class_name Possessable
extends Node

@export var display_name: String

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
	possessions_since_last_investigation += 1
	prints("Possessed:", display_name)

func try_scare() -> bool:
	# TODO: Check ghost energy and consume it before trying to scare
	if not _can_scare:
		return false

	_scare()
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
