class_name Possessable
extends Node

@export var display_name: String

# area for triggering possession
@export var tigger_area: Area3D

# area for scaring targets
@export var scare_area: Area3D

#
@export var max_scare_distance := 1

# a curve for scare effectiveness based on distance
@export var scare_curve: Curve

func _can_scare() -> bool:
	return false

func _scare() -> void:
	pass
