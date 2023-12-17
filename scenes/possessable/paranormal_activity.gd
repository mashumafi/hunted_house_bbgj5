extends Node

signal contact_made(Possessable) # Called when the ghost can interact with a new object
signal interacted(Possessable) # Called when the ghost interacts with an object
signal end_game(bool, String) #

var investigations : Array[Possessable] = []
var recently_interacted : Array[Possessable] = []

func _ready() -> void:
	contact_made.connect(_contact_made)

var last_contact : Possessable = null
func _contact_made(p: Possessable, entered: bool) -> void:
	if entered:
		last_contact = p
	elif last_contact == p:
		last_contact = null

func get_possessables() -> Array[Possessable]:
	var possessables : Array[Possessable] = []
	for possessable: Possessable in get_tree().get_nodes_in_group("possessable"):
		possessables.push_back(possessable)
	return possessables

func filter_no_activity(possables: Array[Possessable]) -> Array[Possessable]:
	return get_possessables().filter(func(possessable: Possessable) -> bool:
		return possessable.interactions_since_last_investigation > 0
	)

func filter_far_away(possables: Array[Possessable], global_position: Vector3, distance: float) -> Array[Possessable]:
	return possables.filter(func(a: Possessable) -> bool:
		return a.trigger_area.global_position.distance_squared_to(global_position) <= distance
	)

func sort_by_activity(possessables: Array[Possessable]):
	possessables.sort_custom(func(a: Possessable, b: Possessable) -> bool:
		return a.interactions_since_last_investigation < b.interactions_since_last_investigation
	)

func sort_by_distance(possessables: Array[Possessable], global_position: Vector3):
	possessables.sort_custom(func(a: Possessable, b: Possessable) -> bool:
		return a.trigger_area.global_position.distance_squared_to(global_position) < b.trigger_area.global_position.distance_squared_to(global_position)
	)

func spawn_ghost(node: Node3D):
	var ghost := preload("res://scenes/ghosts/basic_ghost.tscn").instantiate()
	var camera := preload("res://scenes/camera.tscn").instantiate()
	var parent := node.get_parent()
	HUD.show()
	ghost.add_child(camera)
	parent.add_child(ghost)
	camera.current = true
	ghost.global_position = node.global_position
	node.queue_free()
